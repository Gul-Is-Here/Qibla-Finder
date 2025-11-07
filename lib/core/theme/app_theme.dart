import 'package:flutter/material.dart';

/// App Theme Configuration
class AppTheme {
  // Purple Theme Colors (matching Quran screen)
  static const Color primaryColor = Color(0xFF8F66FF); // Main purple
  static const Color secondaryColor = Color(0xFFAB80FF); // Light purple
  static const Color surfaceColor = Color(0xFF2D1B69); // Dark purple
  static const Color backgroundColor = Color(0xFFE8E4F3); // Light purple background
  static const Color accentColor = Color(0xFF9F70FF); // Accent purple

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, // Changed to light for better purple theme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryColor),
      iconTheme: const IconThemeData(color: primaryColor),
    );
  }
}
