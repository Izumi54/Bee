import 'package:flutter/material.dart';

/// App color palette for Bee fintech application
/// Based on design analysis from Figma
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primaryOrange = Color(0xFFFFA719);
  static const Color goldYellow = Color(0xFFFFD419);
  static const Color mustard = Color(0xFFEFB134);

  // Accent Colors
  static const Color tealCyan = Color(0xFF25CDB3);
  static const Color successGreen = Color(0xFF00C006);
  static const Color errorRed = Color(0xFFF70004);

  // Neutral Colors - Light
  static const Color grayLight1 = Color(0xFFF5F5F5);
  static const Color grayLight2 = Color(0xFFF7F7F7);
  static const Color grayLight3 = Color(0xFFF3F4F6);
  static const Color grayLight4 = Color(0xFFF6F6F6);

  // Neutral Colors - Medium
  static const Color grayMedium1 = Color(0xFFD9D9D9);
  static const Color grayMedium2 = Color(0xFFC0C0C0);
  static const Color grayMedium3 = Color(0xFFBEBEBE);
  static const Color grayMedium4 = Color(0xFFCDCDCD);
  static const Color grayMedium5 = Color(0xFFE0E0E0);
  static const Color grayMedium6 = Color(0xFFE2E2E2);
  static const Color grayMedium7 = Color(0xFFE4E4E4);
  static const Color grayMedium8 = Color(0xFFC4C4C4);
  static const Color grayMedium9 = Color(0xFFCCCCCC);
  static const Color grayMedium10 = Color(0xFFAEAEAE);

  // Neutral Colors - Dark
  static const Color grayDark1 = Color(0xFF757575);
  static const Color grayDark2 = Color(0xFF706F6F);
  static const Color grayDark3 = Color(0xFF939393);
  static const Color grayDark4 = Color(0xFF818181);

  // Base Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic Colors (easier to use)
  static const Color primary = primaryOrange;
  static const Color accent = goldYellow;
  static const Color success = successGreen;
  static const Color error = errorRed;
  static const Color warning = mustard;
  static const Color info = tealCyan;

  // Text Colors
  static const Color textPrimary = black;
  static const Color textSecondary = grayDark1;
  static const Color textTertiary = grayDark2;
  static const Color textHint = grayMedium10;
  static const Color textDisabled = grayMedium1;

  // Background Colors
  static const Color backgroundPrimary = white;
  static const Color backgroundSecondary = grayLight1;
  static const Color backgroundTertiary = grayLight3;
  static const Color backgroundGray = grayLight1; // For home screen

  // Border Colors
  static const Color borderLight = grayMedium1;
  static const Color borderMedium = grayMedium2;
  static const Color borderDark = grayMedium4;

  // Input Colors
  static const Color inputBackground = grayLight1;
  static const Color inputBorder = grayMedium2;
  static const Color inputBorderFocused = tealCyan;
  static const Color inputLabel = primaryOrange;

  // Button Colors
  static const Color buttonPrimary = primaryOrange;
  static const Color buttonSecondary = white;
  static const Color buttonDisabled = grayMedium1;

  // Card Colors
  static const Color cardBackground = white;
  static const Color cardShadow = Color(0x3F000000);

  // Shadow Colors
  static const Color shadowLight = Color(0x2B000000);
  static const Color shadowMedium = Color(0x3F000000);

  // Transaction Colors
  static const Color transactionIncome = successGreen;
  static const Color transactionExpense = errorRed;
}
