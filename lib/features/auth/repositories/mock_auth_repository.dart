import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _usersKey = 'auth.users';
  static const _sessionKey = 'auth.session_phone';

  Map<String, AppUser> get _users {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, AppUser.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> _saveUser(AppUser user) {
    final users = {..._users, user.phone: user};
    return _prefs.setString(
      _usersKey,
      jsonEncode(users.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  @override
  AppUser? currentUser() {
    final phone = _prefs.getString(_sessionKey);
    return phone == null ? null : _users[phone];
  }

  @override
  Future<void> sendOtp(String phone) => Future.delayed(AppConstants.mockLatency);

  @override
  Future<AppUser?> verifyOtp({required String phone, required String otp}) async {
    await Future.delayed(AppConstants.mockLatency);
    if (otp != AppConstants.mockOtp) throw const AppException('Incorrect OTP. Please try again.');
    final user = _users[phone];
    if (user != null) await _prefs.setString(_sessionKey, phone);
    return user;
  }

  @override
  Future<AppUser> register({required String phone, required String name, String? email}) async {
    await Future.delayed(AppConstants.mockLatency);
    final user = AppUser(phone: phone, name: name.trim(), email: _clean(email));
    await _saveUser(user);
    await _prefs.setString(_sessionKey, phone);
    return user;
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await Future.delayed(AppConstants.mockLatency);
    final updated = user.copyWith(name: user.name.trim(), email: _clean(user.email));
    await _saveUser(updated);
    return updated;
  }

  @override
  Future<void> signOut() => _prefs.remove(_sessionKey);

  String? _clean(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }
}
