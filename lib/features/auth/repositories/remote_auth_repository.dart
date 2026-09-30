import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_call.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/storage/token_store.dart';
import '../models/app_user.dart';
import '../models/auth_session_model.dart';
import 'auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._dio, this._tokens, this._prefs);

  final Dio _dio;
  final TokenStore _tokens;
  final SharedPreferences _prefs;

  static const _userKey = 'auth.cached_user';

  @override
  AppUser? currentUser() {
    if (_tokens.accessToken == null) return null;
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> sendOtp(String phone) => apiCall(() async {
        await _dio.post<void>(Endpoints.sendOtp, data: {'phone': phone});
      });

  @override
  Future<AppUser?> verifyOtp({required String phone, required String otp}) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          Endpoints.verifyOtp,
          data: {'phone': phone, 'otp': otp},
        );
        final session = AuthSessionModel.fromJson(res.data ?? const {});
        // Token is kept even for new users: register() is an authenticated call.
        await _tokens.save(access: session.token, refresh: session.refreshToken);
        final user = session.isNewUser ? null : session.user;
        if (user != null) await _cacheUser(user);
        return user;
      });

  @override
  Future<AppUser> register({required String phone, required String name, String? email}) =>
      apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          Endpoints.register,
          data: {
            'phone': phone,
            'name': name.trim(),
            if (_clean(email) != null) 'email': _clean(email),
          },
        );
        return _saveUserFrom(res.data);
      });

  @override
  Future<AppUser> updateProfile(AppUser user) => apiCall(() async {
        final res = await _dio.put<Map<String, dynamic>>(
          Endpoints.me,
          data: {
            'name': user.name.trim(),
            'email': _clean(user.email),
          },
        );
        return _saveUserFrom(res.data);
      });

  @override
  Future<void> signOut() async {
    try {
      await _dio.post<void>(Endpoints.logout);
    } on DioException {
      // Best effort: the local session is cleared regardless.
    }
    await _tokens.clear();
    await _prefs.remove(_userKey);
  }

  Future<AppUser> _saveUserFrom(Map<String, dynamic>? body) async {
    final json = (body?['user'] ?? body) as Map<String, dynamic>;
    final user = AppUser.fromJson(json);
    await _cacheUser(user);
    return user;
  }

  Future<void> _cacheUser(AppUser user) => _prefs.setString(_userKey, jsonEncode(user.toJson()));

  String? _clean(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }
}
