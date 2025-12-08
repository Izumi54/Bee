import 'dart:math';
import 'package:flutter/material.dart';

/// Helper class untuk handle responsive sizing
/// Membantu aplikasi beradaptasi di berbagai ukuran screen Android
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  /// Mendapatkan lebar screen
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Mendapatkan tinggi screen
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Kategori ukuran screen
  bool get isSmallScreen => screenWidth < 360; // 320-359px
  bool get isMediumScreen =>
      screenWidth >= 360 && screenWidth < 400; // 360-399px
  bool get isLargeScreen => screenWidth >= 400; // 400px+

  /// Width percentage - wp(50) = 50% dari lebar screen
  double wp(double percentage) => screenWidth * (percentage / 100);

  /// Height percentage - hp(50) = 50% dari tinggi screen
  double hp(double percentage) => screenHeight * (percentage / 100);

  /// Button width responsive
  double get buttonWidth {
    if (isSmallScreen) {
      return screenWidth * 0.9; // 90% untuk screen kecil
    } else if (isMediumScreen) {
      return screenWidth * 0.85; // 85% untuk screen medium
    } else {
      return min(320, screenWidth * 0.8); // Max 320px atau 80%
    }
  }

  /// Logo size responsive
  double get logoSizeLarge {
    if (isSmallScreen) {
      return screenWidth * 0.5; // 50% untuk screen kecil
    } else if (isMediumScreen) {
      return screenWidth * 0.4; // 40% untuk screen medium
    } else {
      return min(150, screenWidth * 0.35); // Max 150px
    }
  }

  /// Logo size medium
  double get logoSizeMedium {
    if (isSmallScreen) {
      return screenWidth * 0.35;
    } else if (isMediumScreen) {
      return screenWidth * 0.3;
    } else {
      return min(120, screenWidth * 0.25);
    }
  }

  /// Logo size small
  double get logoSizeSmall {
    if (isSmallScreen) {
      return screenWidth * 0.2;
    } else if (isMediumScreen) {
      return screenWidth * 0.18;
    } else {
      return min(80, screenWidth * 0.15);
    }
  }

  /// Horizontal padding screen
  double get horizontalPadding {
    if (isSmallScreen) {
      return 20.0;
    } else if (isMediumScreen) {
      return 24.0;
    } else {
      return 28.0;
    }
  }

  /// Vertical padding screen
  double get verticalPadding {
    if (isSmallScreen) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  /// Max content width untuk tablet
  double get maxContentWidth => 600.0;

  /// Font size scale untuk small screens
  double get fontScale {
    if (isSmallScreen) {
      return 0.95; // Sedikit lebih kecil untuk screen kecil
    }
    return 1.0;
  }

  /// Spacing scale
  double spacing(double baseSpacing) {
    if (isSmallScreen) {
      return baseSpacing * 0.85;
    }
    return baseSpacing;
  }
}

/// Extension untuk mudah akses ResponsiveHelper
extension ResponsiveExtension on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}
