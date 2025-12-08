/// App dimensions and spacing constants
/// Following 8px grid system for consistency
class AppDimensions {
  AppDimensions._(); // Private constructor

  // Spacing Scale (8px grid system)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Padding - Screen
  static const double paddingScreenHorizontal = 28.0;
  static const double paddingScreenVertical = 24.0;
  static const double paddingScreenTop = 40.0;

  // Padding - Components
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Margins
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 999.0; // For pill-shaped buttons

  // Border Radius - Specific Components
  static const double radiusButton = 24.0;
  static const double radiusCard = 19.0;
  static const double radiusInput = 17.0;
  static const double radiusBottomSheet = 25.0;

  // Button Sizes
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 54.0;
  static const double buttonWidthFull = double.infinity;
  static const double buttonWidthStandard = 298.0;

  // Input Field Sizes
  static const double inputHeight = 56.0;
  static const double inputBorderWidth = 1.0;
  static const double inputFocusedBorderWidth = 2.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Logo Sizes
  static const double logoSmall = 80.0;
  static const double logoMedium = 120.0;
  static const double logoLarge = 250.0;

  // PIN Input
  static const double pinDotSize = 16.0;
  static const double pinDotSpacing = 12.0;
  static const double pinButtonSize = 72.0;
  static const double pinButtonSpacing = 16.0;

  // Card Sizes
  static const double cardElevation = 2.0;
  static const double cardHeight = 181.0;
  static const double cardMinHeight = 100.0;

  // Bottom Navigation Bar
  static const double bottomNavHeight = 70.0;
  static const double bottomNavIconSize = 26.0;

  // Quick Action Button
  static const double quickActionSize = 51.0;
  static const double quickActionSpacing = 16.0;

  // Avatar/Profile Picture
  static const double avatarSmall = 40.0;
  static const double avatarMedium = 60.0;
  static const double avatarLarge = 80.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;

  // Shadow
  static const double shadowElevationLow = 2.0;
  static const double shadowElevationMedium = 4.0;
  static const double shadowElevationHigh = 8.0;

  // Carousel/PageView Indicators
  static const double indicatorDotSize = 7.0;
  static const double indicatorDotActiveWidth = 22.0;
  static const double indicatorDotSpacing = 4.0;

  // Transaction List Item
  static const double transactionItemHeight = 80.0;
  static const double transactionIconSize = 20.0;

  // Minimum Touch Target Size (accessibility)
  static const double minTouchTarget = 48.0;

  // Bottom Sheet
  static const double bottomSheetHandleWidth = 60.0;
  static const double bottomSheetHandleHeight = 3.0;
  static const double bottomSheetTopPadding = 16.0;

  // Animation Duration (in milliseconds)
  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;

  // Max Content Width (for large screens)
  static const double maxContentWidth = 600.0;
}
