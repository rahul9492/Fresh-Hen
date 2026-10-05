abstract final class AppConstants {
  static const appName = 'Fresh Hen';
  static const otpLength = 4;
  static const otpResendSeconds = 30;
  static const mockOtp = '1234';
  static const filterPriceMax = 900;
  static const mockLatency = Duration(milliseconds: 450);

  /// Help & Support number for calls and WhatsApp.
  /// Fallback until the admin app's support number loads.
  static const supportPhone = '+919711739492';
}

abstract final class Assets {
  static const _dir = 'assets/images';
  static const splash1 = '$_dir/splash1.png';
  static const splash2 = '$_dir/splash2.png';
  static const splash3 = '$_dir/splash3.png';
  static const chickenCurry = '$_dir/chicken_curry_cut.jpg';
  static const chickenDrumstick = '$_dir/chicken_drumstick.jpg';
  static const chickenBoneless = '$_dir/chicken_boneless.jpg';
  static const chickenBreast = '$_dir/chicken_breast.jpg';
  static const chickenLeg = '$_dir/chicken_leg.jpg';
  static const chickenWings = '$_dir/chicken_wings.jpg';
  static const chickenLiver = '$_dir/chicken_liver.jpg';
  static const eggBasket = '$_dir/egg_basket.jpg';
  static const eggClassic = '$_dir/egg_classic.jpg';
  static const eggCountry = '$_dir/egg_country.jpg';
  static const eggCarton = '$_dir/egg_carton.jpg';
  static const eggTray = '$_dir/egg_tray.jpg';
  static const masalaChicken = '$_dir/masala_chicken.jpg';
  static const masalaMeat = '$_dir/masala_meat.jpg';
  static const pasteGingerGarlic = '$_dir/paste_ginger_garlic.jpg';
  static const lemon = '$_dir/lemon.jpg';
  static const countryHen = '$_dir/country_hen.jpg';
  static const countryHenRaw = '$_dir/country_hen_raw.jpg';
  static const chicken = '$_dir/chicken.jpg';
  static const duck = '$_dir/duck.jpg';
  static const mutton = '$_dir/mutton.jpg';
  static const mutton2 = '$_dir/mutton2.jpg';
  static const fish = '$_dir/fish.jpg';
  static const fish2 = '$_dir/fish2.jpg';
  static const mockUpiQr = '$_dir/mock_upi_qr.png';
}
