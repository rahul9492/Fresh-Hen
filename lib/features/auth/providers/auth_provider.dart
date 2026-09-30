import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/session_expired_provider.dart';
import '../models/app_user.dart';
import 'auth_repository_provider.dart';

part 'auth_provider.g.dart';

enum OtpOutcome { failed, registered, newUser }

@Riverpod(keepAlive: true)
class AuthSession extends _$AuthSession {
  @override
  AppUser? build() {
    ref.listen(sessionExpiredProvider, (_, _) => signOut());
    return ref.read(authRepositoryProvider).currentUser();
  }

  void signIn(AppUser user) => state = user;

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

@Riverpod(keepAlive: true)
String? sessionPhone(Ref ref) => ref.watch(authSessionProvider)?.phone;

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<bool> sendOtp(String phone) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).sendOtp(phone));
    return !state.hasError;
  }
}

@riverpod
class OtpController extends _$OtpController {
  @override
  FutureOr<void> build() {}

  Future<OtpOutcome> verify({required String phone, required String otp}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).verifyOtp(phone: phone, otp: otp),
    );
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return OtpOutcome.failed;
    }
    state = const AsyncData(null);
    final user = result.requireValue;
    if (user == null) return OtpOutcome.newUser;
    ref.read(authSessionProvider.notifier).signIn(user);
    return OtpOutcome.registered;
  }
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {}

  Future<bool> register({required String phone, required String name, String? email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .register(phone: phone, name: name, email: email);
      ref.read(authSessionProvider.notifier).signIn(user);
    });
    return !state.hasError;
  }

  Future<bool> saveChanges({required String name, String? email}) async {
    final current = ref.read(authSessionProvider);
    if (current == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .updateProfile(current.copyWith(name: name, email: email));
      ref.read(authSessionProvider.notifier).signIn(user);
    });
    return !state.hasError;
  }
}

@riverpod
class OtpCountdown extends _$OtpCountdown {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    _start();
    return AppConstants.otpResendSeconds;
  }

  void restart() {
    state = AppConstants.otpResendSeconds;
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state <= 1) {
        state = 0;
        t.cancel();
      } else {
        state = state - 1;
      }
    });
  }
}
