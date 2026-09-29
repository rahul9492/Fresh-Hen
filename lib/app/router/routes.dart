abstract final class Routes {
  static const root = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const categories = '/categories';
  static const orders = '/orders';
  static const account = '/account';
  static const cart = '/cart';
  static const search = '/search';
  static const products = '/products';
  static const orderSuccess = '/order-success';

  static const publicRoutes = {root, onboarding, login, otp, profileSetup};

  static String otpFor(String phone) => Uri(path: otp, queryParameters: {'phone': phone}).toString();

  static String profileSetupFor(String phone) =>
      Uri(path: profileSetup, queryParameters: {'phone': phone}).toString();

  static String productsFor({required String title, String? category, String? section}) => Uri(
        path: products,
        queryParameters: {
          'title': title,
          'category': ?category,
          'section': ?section,
        },
      ).toString();

  static String orderSuccessFor(String orderId) =>
      Uri(path: orderSuccess, queryParameters: {'id': orderId}).toString();
}
