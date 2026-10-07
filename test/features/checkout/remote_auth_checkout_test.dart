import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/core/network/endpoints.dart';
import 'package:fresh_hen/core/storage/token_store.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/repositories/remote_auth_repository.dart';
import 'package:fresh_hen/features/checkout/repositories/checkout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers each request from [reply] (status + body) and remembers it.
class _Api implements HttpClientAdapter {
  _Api([this.reply = _ok]);

  (int, Object) Function(RequestOptions) reply;
  final requests = <RequestOptions>[];
  RequestOptions get last => requests.last;

  static (int, Object) _ok(RequestOptions _) => (200, <String, Object>{});

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? _, Future<void>? _) async {
    requests.add(o);
    final (status, body) = reply(o);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_Api api) => Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = api;

const _userJson = {'phone': '9876543210', 'name': 'Rahul Kumar', 'email': 'r@x.com'};

Future<(RemoteAuthRepository, _Api, TokenStore, SharedPreferences)> _auth([_Api? api]) async {
  FlutterSecureStorage.setMockInitialValues({});
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final tokens = TokenStore();
  final a = api ?? _Api();
  return (RemoteAuthRepository(_dio(a), tokens, prefs), a, tokens, prefs);
}

void main() {
  group('remote auth', () {
    test('nobody is signed in without a token, or without a cached user', () async {
      final (repo, _, tokens, prefs) = await _auth();
      expect(repo.currentUser(), isNull);

      await tokens.save(access: 'a');
      expect(repo.currentUser(), isNull); // token but no user yet

      await prefs.setString('auth.cached_user', jsonEncode(_userJson));
      expect(repo.currentUser()?.name, 'Rahul Kumar');

      await tokens.clear();
      expect(repo.currentUser(), isNull); // user kept but token gone
    });

    test('sending an OTP posts the phone', () async {
      final (repo, api, _, _) = await _auth();
      await repo.sendOtp('9876543210');
      expect(api.last.path, Endpoints.sendOtp);
      expect(api.last.data, {'phone': '9876543210'});
    });

    test('verifying a known number keeps the tokens and caches the user', () async {
      final api = _Api(
        (_) => (200, {'token': 'T', 'refreshToken': 'R', 'isNewUser': false, 'user': _userJson}),
      );
      final (repo, _, tokens, prefs) = await _auth(api);

      final user = await repo.verifyOtp(phone: '9876543210', otp: '1234');

      expect(api.last.path, Endpoints.verifyOtp);
      expect(api.last.data, {'phone': '9876543210', 'otp': '1234'});
      expect(user?.name, 'Rahul Kumar');
      expect(tokens.accessToken, 'T');
      expect(tokens.refreshToken, 'R');
      expect(prefs.getString('auth.cached_user'), isNotNull);
      expect(repo.currentUser()?.phone, '9876543210');
    });

    test('verifying a new number keeps the token but gives no user', () async {
      final api = _Api((_) => (200, {'token': 'T', 'isNewUser': true}));
      final (repo, _, tokens, prefs) = await _auth(api);

      final user = await repo.verifyOtp(phone: '9000000001', otp: '1234');

      expect(user, isNull);
      expect(tokens.accessToken, 'T'); // register() is an authenticated call
      expect(prefs.getString('auth.cached_user'), isNull);
    });

    test('a wrong OTP surfaces the server message', () async {
      final api = _Api((_) => (400, {'message': 'Incorrect OTP'}));
      final (repo, _, tokens, _) = await _auth(api);
      await expectLater(
        repo.verifyOtp(phone: '9876543210', otp: '0000'),
        throwsA(isA<AppException>().having((e) => e.message, 'message', 'Incorrect OTP')),
      );
      expect(tokens.accessToken, isNull);
    });

    test('registering sends a trimmed name and only a real email, and signs in', () async {
      final api = _Api((_) => (200, {'user': _userJson}));
      final (repo, _, _, _) = await _auth(api);

      await repo.register(phone: '9876543210', name: '  Rahul Kumar  ', email: '   ');
      expect(api.last.path, Endpoints.register);
      expect(api.last.data, {'phone': '9876543210', 'name': 'Rahul Kumar'});

      await repo.register(phone: '9876543210', name: 'Rahul', email: ' r@x.com ');
      expect(api.last.data, {'phone': '9876543210', 'name': 'Rahul', 'email': 'r@x.com'});
      expect(repo.currentUser, isNotNull);
    });

    test('a response without a user wrapper is read as the user itself', () async {
      final api = _Api((_) => (200, _userJson));
      final (repo, _, _, prefs) = await _auth(api);
      final user = await repo.register(phone: '9876543210', name: 'Rahul Kumar');
      expect(user.email, 'r@x.com');
      expect(prefs.getString('auth.cached_user'), contains('Rahul Kumar'));
    });

    test('updating the profile puts the trimmed details and refreshes the cache', () async {
      final api = _Api(
        (_) => (
          200,
          {
            'user': {..._userJson, 'name': 'Rahul K'},
          },
        ),
      );
      final (repo, _, _, prefs) = await _auth(api);

      final updated = await repo.updateProfile(
        const AppUser(phone: '9876543210', name: ' Rahul K ', email: ' '),
      );

      expect(api.last.method, 'PUT');
      expect(api.last.path, Endpoints.me);
      expect(api.last.data, {'name': 'Rahul K', 'email': null});
      expect(updated.name, 'Rahul K');
      expect(prefs.getString('auth.cached_user'), contains('Rahul K'));
    });

    test(
      'signing out clears everything, and still does when the server cannot be reached',
      () async {
        final api = _Api((_) => (500, {'message': 'down'}));
        final (repo, _, tokens, prefs) = await _auth(api);
        await tokens.save(access: 'a', refresh: 'r');
        await prefs.setString('auth.cached_user', jsonEncode(_userJson));

        await repo.signOut();

        expect(api.last.path, Endpoints.logout);
        expect(tokens.accessToken, isNull);
        expect(tokens.refreshToken, isNull);
        expect(prefs.getString('auth.cached_user'), isNull);
      },
    );

    test('deleting the account clears the session', () async {
      final (repo, api, tokens, prefs) = await _auth();
      await tokens.save(access: 'a');
      await prefs.setString('auth.cached_user', jsonEncode(_userJson));

      await repo.deleteAccount();

      expect(api.last.method, 'DELETE');
      expect(api.last.path, Endpoints.me);
      expect(tokens.accessToken, isNull);
      expect(prefs.getString('auth.cached_user'), isNull);
    });

    test('a refused deletion is reported and keeps the session', () async {
      final api = _Api((_) => (409, {'message': 'You have an open order'}));
      final (repo, _, tokens, prefs) = await _auth(api);
      await tokens.save(access: 'a');
      await prefs.setString('auth.cached_user', jsonEncode(_userJson));

      await expectLater(
        repo.deleteAccount(),
        throwsA(isA<AppException>().having((e) => e.message, 'message', 'You have an open order')),
      );
      expect(tokens.accessToken, 'a');
      expect(prefs.getString('auth.cached_user'), isNotNull);
    });
  });

  group('token store', () {
    test('saves, reloads after a restart, and clears', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final first = TokenStore();
      await first.save(access: 'a1', refresh: 'r1');

      final second = TokenStore();
      expect(second.accessToken, isNull); // nothing loaded yet
      await second.load();
      expect(second.accessToken, 'a1');
      expect(second.refreshToken, 'r1');

      await second.clear();
      final third = TokenStore();
      await third.load();
      expect(third.accessToken, isNull);
    });

    test('saving a new access token keeps the existing refresh token', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final store = TokenStore();
      await store.save(access: 'a1', refresh: 'r1');
      await store.save(access: 'a2');
      expect(store.accessToken, 'a2');
      expect(store.refreshToken, 'r1');
    });
  });

  group('remote checkout', () {
    test('reads the store settings', () async {
      final api = _Api(
        (_) => (
          200,
          {
            'data': {
              'deliveryFee': 30,
              'deliveryPincodes': ['201301'],
              'upiQrImage': 'https://x/qr.png',
            },
          },
        ),
      );
      final settings = await RemoteCheckoutRepository(_dio(api)).settings();
      expect(api.last.path, Endpoints.storeSettings);
      expect(settings.deliveryFee, 30);
      expect(settings.deliversTo('201301'), isTrue);
      expect(settings.deliversTo('110001'), isFalse);
      expect(settings.upiEnabled, isTrue);
    });

    test('empty data falls back to the defaults', () async {
      final settings = await RemoteCheckoutRepository(_dio(_Api())).settings();
      expect(settings.deliveryFee, 40);
      expect(settings.deliveryPincodes, isEmpty);
    });

    test('reads delivery days starting today, four days ahead', () async {
      final api = _Api(
        (_) => (
          200,
          {
            'data': [
              {
                'date': '2026-10-08T00:00:00.000',
                'closedReason': 'Weekly off',
                'slots': <Object>[],
              },
              {
                'date': '2026-10-09T00:00:00.000',
                'slots': [
                  {
                    'id': 's1',
                    'start': '2026-10-09T10:00:00.000',
                    'end': '2026-10-09T11:00:00.000',
                    'available': true,
                  },
                ],
              },
            ],
          },
        ),
      );
      final days = await RemoteCheckoutRepository(_dio(api)).deliveryDays();
      expect(api.last.path, Endpoints.deliverySlots);
      expect(api.last.queryParameters['days'], 4);
      expect(api.last.queryParameters['from'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(days.length, 2);
      expect(days.first.isOpen, isFalse);
      expect(days.last.slots.single.id, 's1');
    });

    test('reads the coupons and ignores entries that are not objects', () async {
      final api = _Api(
        (_) => (
          200,
          {
            'data': [
              {'code': 'SAVE50', 'title': 't', 'description': 'd', 'flatOff': 50},
              'junk',
              7,
            ],
          },
        ),
      );
      final coupons = await RemoteCheckoutRepository(_dio(api)).coupons();
      expect(coupons.map((c) => c.code), ['SAVE50']);
    });

    test('no data means no coupons', () async {
      expect(await RemoteCheckoutRepository(_dio(_Api())).coupons(), isEmpty);
    });

    test('checking a code sends it trimmed and in capitals', () async {
      final api = _Api(
        (_) => (
          200,
          {
            'data': {'code': 'SAVE50', 'title': 't', 'description': 'd', 'flatOff': 50},
          },
        ),
      );
      final coupon = await RemoteCheckoutRepository(_dio(api)).findCoupon('  save50 ');
      expect(api.last.path, Endpoints.couponValidate);
      expect(api.last.data, {'code': 'SAVE50'});
      expect(coupon.flatOff, 50);
    });

    test('an unknown code shows the server message', () async {
      final api = _Api((_) => (404, {'message': 'This coupon code is not valid'}));
      await expectLater(
        RemoteCheckoutRepository(_dio(api)).findCoupon('NOPE'),
        throwsA(
          isA<AppException>().having((e) => e.message, 'message', 'This coupon code is not valid'),
        ),
      );
    });

    test('a server error becomes a friendly message', () async {
      final api = _Api((_) => (500, <String, Object>{}));
      await expectLater(
        RemoteCheckoutRepository(_dio(api)).settings(),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'Server error. Please try again later.',
          ),
        ),
      );
    });
  });
}
