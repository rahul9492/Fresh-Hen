import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/network/auth_interceptor.dart';
import 'package:fresh_hen/core/storage/token_store.dart';

/// Answers requests from a script keyed by "METHOD path", recording every call.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final calls = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add('${options.method} ${options.path} [${options.headers['Authorization']}]');
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, dynamic> body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Future<({Dio dio, TokenStore tokens, _FakeAdapter adapter, List<int> expired})> _setup(
  ResponseBody Function(RequestOptions) handler, {
  String? refresh = 'refresh-1',
}) async {
  FlutterSecureStorage.setMockInitialValues({
    'auth.access_token': 'old',
    'auth.refresh_token': ?refresh,
  });
  final tokens = TokenStore();
  await tokens.load();
  final adapter = _FakeAdapter(handler);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter;
  final expired = <int>[];
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      tokens: tokens,
      onUnauthorized: () async {
        expired.add(1);
        await tokens.clear();
      },
    ),
  );
  return (dio: dio, tokens: tokens, adapter: adapter, expired: expired);
}

void main() {
  test('401 refreshes the token once and replays the request', () async {
    final s = await _setup((o) {
      if (o.path == '/auth/refresh') {
        return _json(200, {'token': 'new', 'refreshToken': 'refresh-2'});
      }
      final ok = o.headers['Authorization'] == 'Bearer new';
      return _json(ok ? 200 : 401, {'ok': ok});
    });

    final res = await s.dio.get<Map<String, dynamic>>('/orders');

    expect(res.data, {'ok': true});
    expect(s.tokens.accessToken, 'new');
    expect(s.tokens.refreshToken, 'refresh-2');
    expect(s.expired, isEmpty);
    expect(s.adapter.calls, [
      'GET /orders [Bearer old]',
      'POST /auth/refresh [null]',
      'GET /orders [Bearer new]',
    ]);
  });

  test('parallel 401s share a single refresh', () async {
    final s = await _setup((o) {
      if (o.path == '/auth/refresh') return _json(200, {'token': 'new'});
      final ok = o.headers['Authorization'] == 'Bearer new';
      return _json(ok ? 200 : 401, {});
    });

    await Future.wait([s.dio.get<void>('/a'), s.dio.get<void>('/b'), s.dio.get<void>('/c')]);

    expect(s.adapter.calls.where((c) => c.startsWith('POST /auth/refresh')).length, 1);
    expect(s.expired, isEmpty);
  });

  test('rejected refresh token expires the session', () async {
    final s = await _setup((o) => _json(401, {}));

    await expectLater(s.dio.get<void>('/orders'), throwsA(isA<DioException>()));

    expect(s.expired.length, 1);
    expect(s.tokens.accessToken, isNull);
    expect(s.tokens.refreshToken, isNull);
  });

  test('no refresh token expires the session without calling refresh', () async {
    final s = await _setup((o) => _json(401, {}), refresh: null);

    await expectLater(s.dio.get<void>('/orders'), throwsA(isA<DioException>()));

    expect(s.expired.length, 1);
    expect(s.adapter.calls.any((c) => c.contains('/auth/refresh')), isFalse);
  });

  test('refresh failing on the network keeps the session', () async {
    final s = await _setup((o) {
      if (o.path == '/auth/refresh') return _json(503, {});
      return _json(401, {});
    });

    await expectLater(s.dio.get<void>('/orders'), throwsA(isA<DioException>()));

    expect(s.expired, isEmpty);
    expect(s.tokens.accessToken, 'old');
  });

  test('tokens survive a restart via secure storage', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final first = TokenStore();
    await first.save(access: 'a1', refresh: 'r1');

    final second = TokenStore();
    await second.load();
    expect(second.accessToken, 'a1');
    expect(second.refreshToken, 'r1');

    await second.clear();
    final third = TokenStore();
    await third.load();
    expect(third.accessToken, isNull);
  });
}
