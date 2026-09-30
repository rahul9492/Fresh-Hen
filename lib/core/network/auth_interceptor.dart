import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_store.dart';
import 'endpoints.dart';

/// Adds the bearer token to outgoing requests. On a 401 it tries to refresh the
/// token once and replays the request; only if the refresh is rejected is the
/// session reported as expired.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.tokens, required this.onUnauthorized});

  final Dio dio;
  final TokenStore tokens;
  final Future<void> Function() onUnauthorized;

  static const _retriedKey = 'auth.retried';

  /// Shared by all requests that hit a 401 at the same time, so the refresh
  /// token is only spent once.
  Future<bool>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final isPublic = Endpoints.public.contains(request.path);

    if (!isUnauthorized || isPublic || tokens.accessToken == null) {
      return handler.next(err);
    }

    // Already replayed once with a fresh token and still rejected.
    if (request.extra[_retriedKey] == true) {
      await onUnauthorized();
      return handler.next(err);
    }

    final bool refreshed;
    try {
      refreshed = await (_refreshing ??= _refresh().whenComplete(() => _refreshing = null));
    } on DioException {
      // Offline or server down: keep the session, just fail this request.
      return handler.next(err);
    }

    if (!refreshed) {
      await onUnauthorized();
      return handler.next(err);
    }

    try {
      request.extra[_retriedKey] = true;
      request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      return handler.resolve(await dio.fetch<dynamic>(request));
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Returns true when new tokens were stored, false when the refresh token was
  /// rejected. Network failures are rethrown.
  Future<bool> _refresh() async {
    final refreshToken = tokens.refreshToken;
    if (refreshToken == null) return false;

    // A bare client: going through [dio] would recurse into this interceptor.
    final bare = Dio(BaseOptions(
      baseUrl: dio.options.baseUrl,
      connectTimeout: dio.options.connectTimeout,
      receiveTimeout: dio.options.receiveTimeout,
    ))..httpClientAdapter = dio.httpClientAdapter;

    try {
      final res = await bare.post<Map<String, dynamic>>(
        Endpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final access = res.data?['token'] as String?;
      if (access == null) return false;
      await tokens.save(access: access, refresh: res.data?['refreshToken'] as String?);
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null && status >= 400 && status < 500) return false;
      rethrow;
    }
  }
}
