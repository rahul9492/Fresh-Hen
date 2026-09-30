/// Every API path in one place. Paths are relative to `Env.baseUrl`.
abstract final class Endpoints {
  // Auth
  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const me = '/users/me';

  /// Paths that must never trigger the "session expired" flow on a 401.
  static const public = {sendOtp, verifyOtp};
}
