import 'app_user.dart';

/// Response of the verify-otp / register endpoints.
///
/// Assumed API shape (adjust here when the real contract lands):
/// `{ "token": "...", "isNewUser": false, "user": { "phone", "name", "email" } }`
class AuthSessionModel {
  const AuthSessionModel({required this.token, required this.isNewUser, this.user});

  final String token;
  final bool isNewUser;
  final AppUser? user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return AuthSessionModel(
      token: json['token'] as String,
      isNewUser: json['isNewUser'] as bool? ?? user == null,
      user: user is Map<String, dynamic> ? AppUser.fromJson(user) : null,
    );
  }
}
