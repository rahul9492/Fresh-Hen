// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/constants/app_constants.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/core/models/paginated.dart';
import 'package:fresh_hen/core/network/session_expired_provider.dart';
import 'package:fresh_hen/core/push/push_service.dart';
import 'package:fresh_hen/core/storage/prefs_provider.dart';
import 'package:fresh_hen/features/auth/models/app_user.dart';
import 'package:fresh_hen/features/auth/models/auth_session_model.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/auth/repositories/mock_auth_repository.dart';
import 'package:fresh_hen/features/onboarding/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePush extends PushService {
  _FakePush(super.ref);

  int unregistered = 0;

  @override
  Stream<Map<String, dynamic>> get received => const Stream.empty();

  @override
  Future<void> unregister() async => unregistered++;
}

const _rahul = AppUser(phone: '9876543210', name: 'Rahul Kumar', email: 'r@x.com');

Future<ProviderContainer> _container({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final store = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    sharedPrefsProvider.overrideWithValue(store),
    pushServiceProvider.overrideWith(_FakePush.new),
  ]);
  addTearDown(c.dispose);
  c.listen(authSessionProvider, (_, _) {});
  // The screens watch these while they are open; hold them the same way here.
  c.listen(loginControllerProvider, (_, _) {});
  c.listen(otpControllerProvider, (_, _) {});
  c.listen(profileControllerProvider, (_, _) {});
  return c;
}

Map<String, Object> _registered([AppUser user = _rahul, bool signedIn = true]) => {
      'auth.users': jsonEncode({user.phone: user.toJson()}),
      if (signedIn) 'auth.session_phone': user.phone,
    };

void main() {
  group('models', () {
    test('user helpers', () {
      expect(_rahul.formattedPhone, '+91 9876543210');
      expect(_rahul.firstName, 'Rahul');
      expect(const AppUser(phone: '1', name: '  Asha  Devi ').firstName, 'Asha');
    });

    test('a user survives a JSON round trip', () {
      expect(AppUser.fromJson(_rahul.toJson()), _rahul);
    });

    test('the sign-in response reads the tokens and the user', () {
      final s = AuthSessionModel.fromJson({
        'token': 't',
        'refreshToken': 'r',
        'isNewUser': false,
        'user': _rahul.toJson(),
      });
      expect(s.token, 't');
      expect(s.refreshToken, 'r');
      expect(s.isNewUser, isFalse);
      expect(s.user, _rahul);
    });

    test('with no user, the response says the number is new', () {
      final s = AuthSessionModel.fromJson({'token': 't'});
      expect(s.isNewUser, isTrue);
      expect(s.user, isNull);
      expect(s.refreshToken, isNull);
    });

    test('an explicit isNewUser flag wins', () {
      final s = AuthSessionModel.fromJson({
        'token': 't',
        'isNewUser': true,
        'user': _rahul.toJson(),
      });
      expect(s.isNewUser, isTrue);
    });
  });

  group('errors and pages', () {
    test('an app exception shows its own message; anything else a generic one', () {
      expect(errorMessage(const AppException('Out of stock')), 'Out of stock');
      expect(const AppException('x').toString(), 'x');
      expect(errorMessage(Exception('boom')), 'Something went wrong. Please try again.');
      expect(errorMessage('plain string'), 'Something went wrong. Please try again.');
    });

    test('a page keeps its items and whether more follow', () {
      const p = Paginated<int>(items: [1, 2], page: 0, hasMore: true);
      expect(p.items, [1, 2]);
      expect(p.page, 0);
      expect(p.hasMore, isTrue);
    });
  });

  group('MockAuthRepository', () {
    Future<MockAuthRepository> repo([Map<String, Object> prefs = const {}]) async {
      SharedPreferences.setMockInitialValues(prefs);
      return MockAuthRepository(await SharedPreferences.getInstance());
    }

    test('nobody is signed in on a fresh install', () async {
      expect((await repo()).currentUser(), isNull);
    });

    test('the session phone finds the saved user', () async {
      expect((await repo(_registered())).currentUser(), _rahul);
    });

    test('a saved user is not signed in without a session', () async {
      expect((await repo(_registered(_rahul, false))).currentUser(), isNull);
    });

    test('the wrong OTP is refused', () async {
      final r = await repo(_registered(_rahul, false));
      await expectLater(
        r.verifyOtp(phone: _rahul.phone, otp: '0000'),
        throwsA(isA<AppException>().having((e) => e.message, 'message', contains('Incorrect OTP'))),
      );
      expect(r.currentUser(), isNull);
    });

    test('the right OTP signs a known number in', () async {
      final r = await repo(_registered(_rahul, false));
      final user = await r.verifyOtp(phone: _rahul.phone, otp: AppConstants.mockOtp);
      expect(user, _rahul);
      expect(r.currentUser(), _rahul);
    });

    test('the right OTP on an unknown number gives no user and no session', () async {
      final r = await repo();
      final user = await r.verifyOtp(phone: '9000000001', otp: AppConstants.mockOtp);
      expect(user, isNull);
      expect(r.currentUser(), isNull);
    });

    test('registering saves the user, trims the name, drops a blank email and signs in', () async {
      final r = await repo();
      final user = await r.register(phone: '9000000001', name: '  Asha  ', email: '   ');
      expect(user.name, 'Asha');
      expect(user.email, isNull);
      expect(r.currentUser(), user);
    });

    test('updating the profile saves it', () async {
      final r = await repo(_registered());
      final updated = await r.updateProfile(_rahul.copyWith(name: ' Rahul K ', email: ' new@x.com '));
      expect(updated.name, 'Rahul K');
      expect(updated.email, 'new@x.com');
      expect(r.currentUser(), updated);
    });

    test('signing out clears the session but keeps the account', () async {
      final r = await repo(_registered());
      await r.signOut();
      expect(r.currentUser(), isNull);
      final again = await r.verifyOtp(phone: _rahul.phone, otp: AppConstants.mockOtp);
      expect(again, _rahul);
    });
  });

  group('auth session', () {
    test('starts signed in when the device has a session', () async {
      final c = await _container(prefs: _registered());
      expect(c.read(authSessionProvider), _rahul);
      expect(c.read(sessionPhoneProvider), _rahul.phone);
    });

    test('starts signed out otherwise', () async {
      final c = await _container();
      expect(c.read(authSessionProvider), isNull);
      expect(c.read(sessionPhoneProvider), isNull);
    });

    test('signing out unregisters push, clears the session and the phone', () async {
      final c = await _container(prefs: _registered());
      await c.read(authSessionProvider.notifier).signOut();
      expect(c.read(authSessionProvider), isNull);
      expect(c.read(sessionPhoneProvider), isNull);
      expect((c.read(pushServiceProvider) as _FakePush).unregistered, 1);
    });

    test('an expired session signs the customer out', () async {
      final c = await _container(prefs: _registered());
      expect(c.read(authSessionProvider), isNotNull);
      c.read(sessionExpiredProvider.notifier).notify();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(c.read(authSessionProvider), isNull);
    });
  });

  group('login flow', () {
    test('sending an OTP succeeds', () async {
      final c = await _container();
      final ok = await c.read(loginControllerProvider.notifier).sendOtp('9876543210');
      expect(ok, isTrue);
    });

    test('a known number signs in with the right OTP', () async {
      final c = await _container(prefs: _registered(_rahul, false));
      final outcome = await c
          .read(otpControllerProvider.notifier)
          .verify(phone: _rahul.phone, otp: AppConstants.mockOtp);
      expect(outcome, OtpOutcome.registered);
      expect(c.read(authSessionProvider), _rahul);
    });

    test('an unknown number is asked for its details', () async {
      final c = await _container();
      final outcome = await c
          .read(otpControllerProvider.notifier)
          .verify(phone: '9000000001', otp: AppConstants.mockOtp);
      expect(outcome, OtpOutcome.newUser);
      expect(c.read(authSessionProvider), isNull);
    });

    test('a wrong OTP fails and keeps the error for the screen', () async {
      final c = await _container(prefs: _registered(_rahul, false));
      final outcome = await c
          .read(otpControllerProvider.notifier)
          .verify(phone: _rahul.phone, otp: '9999');
      expect(outcome, OtpOutcome.failed);
      expect(c.read(otpControllerProvider).hasError, isTrue);
      expect(c.read(authSessionProvider), isNull);
    });

    test('registering signs the new customer in', () async {
      final c = await _container();
      final ok = await c
          .read(profileControllerProvider.notifier)
          .register(phone: '9000000001', name: 'Asha', email: 'a@x.com');
      expect(ok, isTrue);
      expect(c.read(authSessionProvider)?.name, 'Asha');
    });

    test('saving profile changes updates the signed-in customer', () async {
      final c = await _container(prefs: _registered());
      final ok = await c
          .read(profileControllerProvider.notifier)
          .saveChanges(name: 'Rahul Singh', email: null);
      expect(ok, isTrue);
      expect(c.read(authSessionProvider)?.name, 'Rahul Singh');
      expect(c.read(authSessionProvider)?.email, isNull);
    });

    test('saving changes does nothing when nobody is signed in', () async {
      final c = await _container();
      final ok = await c
          .read(profileControllerProvider.notifier)
          .saveChanges(name: 'X Y', email: null);
      expect(ok, isFalse);
      expect(c.read(authSessionProvider), isNull);
    });
  });

  group('OTP resend countdown', () {
    test('counts down each second, stops at zero, and can restart', () {
      fakeAsync((async) {
        final c = ProviderContainer();
        addTearDown(c.dispose);
        c.listen(otpCountdownProvider, (_, _) {});

        expect(c.read(otpCountdownProvider), AppConstants.otpResendSeconds);
        async.elapse(const Duration(seconds: 1));
        expect(c.read(otpCountdownProvider), AppConstants.otpResendSeconds - 1);
        async.elapse(const Duration(seconds: 10));
        expect(c.read(otpCountdownProvider), AppConstants.otpResendSeconds - 11);

        async.elapse(const Duration(seconds: 60));
        expect(c.read(otpCountdownProvider), 0);

        c.read(otpCountdownProvider.notifier).restart();
        expect(c.read(otpCountdownProvider), AppConstants.otpResendSeconds);
        async.elapse(const Duration(seconds: 2));
        expect(c.read(otpCountdownProvider), AppConstants.otpResendSeconds - 2);
      });
    });
  });

  group('onboarding', () {
    test('is unseen at first, and remembered once completed', () async {
      final c = await _container();
      c.listen(onboardingSeenProvider, (_, _) {});
      expect(c.read(onboardingSeenProvider), isFalse);

      await c.read(onboardingSeenProvider.notifier).complete();
      expect(c.read(onboardingSeenProvider), isTrue);
    });

    test('stays seen after a restart', () async {
      final c = await _container(prefs: {'onboarding.seen': true});
      expect(c.read(onboardingSeenProvider), isTrue);
    });
  });
}
