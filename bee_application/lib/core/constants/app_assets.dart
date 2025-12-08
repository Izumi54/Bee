/// Asset paths constants for Bee application
class AppAssets {
  AppAssets._(); // Private constructor

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';

  // Logo
  static const String logoFull = '$_imagesPath/bee_logo.png';
  static const String logoIcon = '$_imagesPath/bee_icon.png';
  static const String logoText = '$_imagesPath/bee_text.png';

  // Placeholder (sementara sebelum logo asli)
  static const String logoPlaceholder = '$_imagesPath/logo_placeholder.png';

  // Backgrounds
  static const String organicShapeBackground =
      '$_imagesPath/organic_background.png';

  // Icons
  static const String iconUser = '$_iconsPath/user.png';
  static const String iconEye = '$_iconsPath/eye.png';
  static const String iconEyeOff = '$_iconsPath/eye_off.png';
  static const String iconCamera = '$_iconsPath/camera.png';
  static const String iconTransfer = '$_iconsPath/transfer.png';
  static const String iconQris = '$_iconsPath/qris.png';
  static const String iconDeposit = '$_iconsPath/deposit.png';
  static const String iconRequest = '$_iconsPath/request.png';
  static const String iconHome = '$_iconsPath/home.png';
  static const String iconHistory = '$_iconsPath/history.png';
  static const String iconContact = '$_iconsPath/contact.png';
  static const String iconProfile = '$_iconsPath/profile.png';
  static const String iconBell = '$_iconsPath/bell.png';
  static const String iconCheck = '$_iconsPath/check.png';
  static const String iconClose = '$_iconsPath/close.png';
  static const String iconBackspace = '$_iconsPath/backspace.png';
  static const String iconSearch = '$_iconsPath/search.png';

  // Illustrations
  static const String illustrationKycPlaceholder =
      '$_imagesPath/kyc_placeholder.png';
  static const String illustrationEmptyTransaction =
      '$_imagesPath/empty_transaction.png';
  static const String illustrationSuccess = '$_imagesPath/success.png';

  // Bee watermark/logo for cards
  static const String beeWatermark = '$_imagesPath/bee_watermark.png';
}
