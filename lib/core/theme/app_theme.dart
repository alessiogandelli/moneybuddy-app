import 'package:flutter/material.dart';
import 'style.dart';

/// App theme configuration for MoneyBuddy
class AppTheme {
  // Brand Colors - using new style system
  static const Color primaryGreen = AppStyle.primary;
  static const Color secondaryGreen = AppStyle.secondary;
  static const Color accentBlue = AppStyle.primaryAir100;
  static const Color warningOrange = AppStyle.warning;
  static const Color errorRed = AppStyle.error;
  
  // Neutral Colors - using new style system
  static const Color backgroundLight = AppStyle.background;
  static const Color surfaceWhite = AppStyle.surface;
  static const Color textPrimary = AppStyle.textPrimary;
  static const Color textSecondary = AppStyle.textSecondary;
  static const Color borderGray = AppStyle.border;

  /// Light theme for MoneyBuddy
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    colorScheme: ColorScheme.light(
      primary: AppStyle.primaryGreen,
      secondary: AppStyle.secondary,
      tertiary: AppStyle.primaryAir100,
      surface: AppStyle.lightSurface,
      background: AppStyle.lightBackground,
      error: AppStyle.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppStyle.lightTextPrimary,
      onBackground: AppStyle.lightTextPrimary,
      onError: Colors.white,
    ),
    // Add Frutiger font family from style system
    fontFamily: AppStyle.fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppStyle.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppStyle.getHeadingSmall(false).copyWith(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppStyle.lightCardBackground,
      elevation: 2,
      shadowColor: AppStyle.lightShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyle.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: AppStyle.buttonWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppStyle.lightSurface,
      labelStyle: AppStyle.getBodyMedium(false),
      hintStyle: AppStyle.getBodySmall(false),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppStyle.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppStyle.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppStyle.primaryGreen, width: 2),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: AppStyle.getHeadingLarge(false),
      headlineMedium: AppStyle.getHeadingMedium(false),
      headlineSmall: AppStyle.getHeadingSmall(false),
      bodyLarge: AppStyle.getBodyLarge(false),
      bodyMedium: AppStyle.getBodyMedium(false),
      bodySmall: AppStyle.getBodySmall(false),
      labelLarge: AppStyle.getButtonText(false),
      labelMedium: AppStyle.getBodyMedium(false),
      labelSmall: AppStyle.getCaption(false),
    ),
    scaffoldBackgroundColor: AppStyle.lightBackground,
  );

  /// Dark theme for MoneyBuddy
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    colorScheme: ColorScheme.dark(
      primary: AppStyle.primaryGreen,
      secondary: AppStyle.secondary,
      tertiary: AppStyle.primaryAir100,
      surface: AppStyle.surface,
      background: AppStyle.background,
      error: AppStyle.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppStyle.textPrimary,
      onBackground: AppStyle.textPrimary,
      onError: Colors.white,
    ),
    fontFamily: AppStyle.fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppStyle.darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppStyle.getHeadingSmall(true).copyWith(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppStyle.cardBackground,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyle.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: AppStyle.buttonWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppStyle.cardBackground,
      labelStyle: AppStyle.getBodyMedium(true),
      hintStyle: AppStyle.getBodySmall(true),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppStyle.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppStyle.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppStyle.primaryGreen, width: 2),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: AppStyle.getHeadingLarge(true),
      headlineMedium: AppStyle.getHeadingMedium(true),
      headlineSmall: AppStyle.getHeadingSmall(true),
      bodyLarge: AppStyle.getBodyLarge(true),
      bodyMedium: AppStyle.getBodyMedium(true),
      bodySmall: AppStyle.getBodySmall(true),
      labelLarge: AppStyle.getButtonText(true),
      labelMedium: AppStyle.getBodyMedium(true),
      labelSmall: AppStyle.getCaption(true),
    ),
    scaffoldBackgroundColor: AppStyle.darkBackground,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppStyle.cardBackground,
      selectedItemColor: AppStyle.primaryGreen,
      unselectedItemColor: AppStyle.textSecondary,
      selectedLabelStyle: AppStyle.getCaption(true),
      unselectedLabelStyle: AppStyle.getCaption(true),
    ),
  );
  
  /// Get theme based on brightness preference
  static ThemeData getTheme(bool isDark) {
    return isDark ? darkTheme : lightTheme;
  }
  
  /// Check if current theme is dark
  static bool isDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}