import '../models/app_user.dart';

abstract interface class AuthRepository {
  AppUser? currentUser();

  Future<void> sendOtp(String phone);

  /// Returns the registered user, or null when the number is new.
  Future<AppUser?> verifyOtp({required String phone, required String otp});

  Future<AppUser> register({required String phone, required String name, String? email});

  Future<AppUser> updateProfile(AppUser user);

  Future<void> signOut();

  /// Permanently deletes the signed-in customer's account, then clears the
  /// session like [signOut].
  Future<void> deleteAccount();
}
