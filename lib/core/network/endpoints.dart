/// Every API path in one place. Paths are relative to `Env.baseUrl`.
abstract final class Endpoints {
  // Auth
  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/users/me';

  // Push notifications: this phone's FCM token, registered after login.
  static const devices = '/devices';
  static String device(String token) => '/devices/$token';

  // Catalog (managed from the admin app)
  static const categories = '/categories';
  static const products = '/products';
  static const banners = '/banners';

  // Orders
  static const orders = '/orders';
  static const paymentProofs = '/orders/payment-proofs';
  static String orderRating(String id) => '/orders/${Uri.encodeComponent(id)}/rating';
  static String orderCancel(String id) => '/orders/${Uri.encodeComponent(id)}/cancel';

  // Saved delivery addresses
  static const addresses = '/addresses';
  static String address(String id) => '/addresses/${Uri.encodeComponent(id)}';
  static String addressDefault(String id) => '/addresses/${Uri.encodeComponent(id)}/default';

  // Wishlist
  static const wishlist = '/wishlist';
  static String wishlistItem(String productId) => '/wishlist/${Uri.encodeComponent(productId)}';

  // Checkout (values managed from the admin app)
  static const storeSettings = '/store/settings';
  static const deliverySlots = '/delivery/slots';
  static const coupons = '/coupons';
  static const couponValidate = '/coupons/validate';

  /// Paths that must never trigger the "session expired" flow on a 401.
  static const public = {sendOtp, verifyOtp, refresh};
}
