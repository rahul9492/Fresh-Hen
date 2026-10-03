/// Every API path in one place. Paths are relative to `Env.baseUrl`.
abstract final class Endpoints {
  // Auth
  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/users/me';

  // Notifications
  static const notifications = '/notifications';
  static const notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // Checkout (values managed from the admin app)
  static const storeSettings = '/store/settings';
  static const deliverySlots = '/delivery/slots';
  static const coupons = '/coupons';
  static const couponValidate = '/coupons/validate';

  /// Paths that must never trigger the "session expired" flow on a 401.
  static const public = {sendOtp, verifyOtp, refresh};
}
