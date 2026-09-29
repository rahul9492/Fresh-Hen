abstract final class AppConstants {
  static const appName = 'Fresh Hen';
  static const otpLength = 4;
  static const otpResendSeconds = 30;
  static const mockOtp = '1234';
  static const freeDeliveryThreshold = 499;
  static const deliveryFee = 40;
  static const filterPriceMax = 900;
  static const mockLatency = Duration(milliseconds: 450);
}

abstract final class Assets {
  static const _dir = 'assets/images';
  static const splash1 = '$_dir/splash1.png';
  static const splash2 = '$_dir/splash2.png';
  static const splash3 = '$_dir/splash3.png';
  static const curry = '$_dir/curry.png';
  static const drumstick = '$_dir/drumstick.png';
  static const boneless = '$_dir/boneless.png';
  static const eggs = '$_dir/eggs.png';
}
