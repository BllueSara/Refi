import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AppTheme {
  static const String fontFamily = 'Tajawal';

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background, // White
      primaryColor: AppColors.primaryBlue,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryBlue,
        surface: Colors.white,
        onSurface: AppColors.textMain, // Black87
        onPrimary: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textMain),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
      ),

      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontFamily: fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontFamily: fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontFamily: fontFamily,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textMain,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSub,
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textPlaceholder,
          fontFamily: fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontFamily: fontFamily,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSub,
          fontFamily: fontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textPlaceholder,
          fontSize: 14,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryBlue, size: 24),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    // Dark Colors
    const Color darkBackground = Color(0xFF0F172A); // Slate 900
    const Color darkSurface = Color(0xFF1E293B); // Slate 800
    const Color darkTextMain = Colors.white;
    const Color darkTextSub = Color(0xFF94A3B8); // Slate 400
    const Color darkPrimary = Color(0xFF60A5FA); // Lighter Blue for contrast

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkPrimary,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: AppColors.secondaryBlue,
        surface: darkSurface,
        onSurface: darkTextMain,
        onPrimary: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkTextMain),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextMain,
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: darkTextMain,
          fontFamily: fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextMain,
          fontFamily: fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkTextMain,
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextMain,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: darkTextMain,
          fontFamily: fontFamily,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: darkTextMain,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkTextMain,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkTextSub,
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkTextSub,
          fontFamily: fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: darkTextMain,
          fontFamily: fontFamily,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: darkTextSub,
          fontFamily: fontFamily,
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkSurface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: darkTextSub, fontSize: 14),
      ),
      iconTheme: const IconThemeData(color: darkPrimary, size: 24),
    );
  }
}
