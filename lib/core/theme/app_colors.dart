import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors - Saffron / Bagwa Theme
  static const Color primaryColor = Color(0xFFFF6F00);   // Deep Saffron
  static const Color secondaryColor = Color(0xFFFF8F00); // Amber-Saffron
  static const Color accentColor = Color(0xFFFFB300);    // Golden Amber
  static const Color lightPink = Color(0xFFFFF3E0);      // Very Light Orange (replaces lightPink)
  static const Color softPink = Color(0xFFFFE0B2);       // Soft Peach (replaces softPink)
  static const Color deepPink = Color(0xFFE65100);       // Deep Saffron Dark
  static const Color goldAccent = Color(0xFFFFD700);     // Gold for premium feel
  static const Color fieldBackground = Color(0xFFF9F9F9); // Light off-white for inputs
  static const Color lightYellow = Color(0xFFFFF9C4);    // Light yellow for banners
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color surfaceColor = Color(0xFFF5F5F5);

  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color scaffoldBackgroundColor = Colors.white;

  static const Color textColorPrimary = Color(0xFF212121);
  static const Color textColorSecondary = Color(0xFF757575);
  static const Color textColorHint = Color(0xFFBDBDBD);

  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFFFF8F00);   // Amber-Saffron for dark mode
  static const Color darkSecondaryColor = Color(0xFFFFB300); // Golden for dark
  static const Color darkAccentColor = Color(0xFFFFD54F);    // Amber-light for contrast

  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkScaffoldBackgroundColor = Color(0xFF121212);

  static const Color darkTextColorPrimary = Color(0xFFFFFFFF);
  static const Color darkTextColorSecondary = Color(0xFFB3B3B3);
  static const Color darkTextColorHint = Color(0xFF888888);

  static const Color darkBorderColor = Color(0xFF333333);
  static const Color darkDividerColor = Color(0xFF333333);

  // Common colors
  static const Color errorColor = Color(0xFFD32F2F);  // Red
  static const Color successColor = Color(0xFF388E3C); // Green
  static const Color warningColor = Color(0xFFFFA000); // Amber
  static const Color infoColor = Color(0xFF1976D2);   // Blue
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Saffron Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    stops: [0.0, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient pinkWhiteGradient = LinearGradient(
    colors: [Colors.white, lightPink, primaryColor],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient verticalGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient pinkWhiteMixGradient = LinearGradient(
    colors: [
      primaryColor,
      Colors.white,
    ],
    stops: const [0.8, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
