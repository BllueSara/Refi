import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';

/// App Theme Configuration
///
/// Note: This theme provides base static values. For responsive sizing,
/// widgets should use ResponsiveUtil from '../utils/responsive_utils.dart'
/// to override theme values (font sizes, padding, radius, etc.) when needed.
///
/// Example:
/// ```dart
/// Text(
///   'Hello',
///   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
///     fontSize: 16.sp(context), // Using responsive utils
///   ),
/// )
/// ```refi
class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
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
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
            color: AppColors.textMain, size: getResponsiveFontSize(24)),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: getResponsiveFontSize(20),
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
      ),

      // Typography
      textTheme: GoogleFonts.tajawalTextTheme(
        TextTheme(
          headlineLarge: TextStyle(
            fontSize: getResponsiveFontSize(34),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          headlineMedium: TextStyle(
            fontSize: getResponsiveFontSize(20),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          headlineSmall: TextStyle(
            fontSize: getResponsiveFontSize(18),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          titleLarge: TextStyle(
            fontSize: getResponsiveFontSize(20),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          titleMedium: TextStyle(
            fontSize: getResponsiveFontSize(16),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          titleSmall: TextStyle(
            fontSize: getResponsiveFontSize(14),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          bodyLarge: TextStyle(
            fontSize: getResponsiveFontSize(16),
            fontWeight: FontWeight.w500,
            color: AppColors.textMain,
          ),
          bodyMedium: TextStyle(
            fontSize: getResponsiveFontSize(14),
            fontWeight: FontWeight.w500,
            color: AppColors.textSub,
          ),
          bodySmall: TextStyle(
            fontSize: getResponsiveFontSize(12),
            fontWeight: FontWeight.normal,
            color: AppColors.textPlaceholder,
          ),
          labelLarge: TextStyle(
            fontSize: getResponsiveFontSize(14),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          labelSmall: TextStyle(
            fontSize: getResponsiveFontSize(12),
            fontWeight: FontWeight.bold,
            color: AppColors.textSub,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(getResponsiveRadius(24))),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(getResponsiveRadius(24))),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: getResponsiveWidth(24),
          vertical: getResponsiveHeight(16),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(getResponsiveRadius(24)),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(getResponsiveRadius(24)),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(getResponsiveRadius(24)),
          borderSide: BorderSide(
              color: AppColors.primaryBlue, width: getResponsiveWidth(2)),
        ),
        hintStyle: TextStyle(
          color: AppColors.textPlaceholder,
          fontSize: getResponsiveFontSize(14),
        ),
      ),
      iconTheme: IconThemeData(
          color: AppColors.primaryBlue, size: getResponsiveFontSize(24)),
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

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme:
            IconThemeData(color: darkTextMain, size: getResponsiveFontSize(24)),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: getResponsiveFontSize(20),
          fontWeight: FontWeight.bold,
          color: darkTextMain,
        ),
      ),

      textTheme: GoogleFonts.tajawalTextTheme(
        TextTheme(
          headlineLarge: TextStyle(
            fontSize: getResponsiveFontSize(34),
            fontWeight: FontWeight.bold,
            color: darkTextMain,
          ),
          headlineMedium: TextStyle(
            fontSize: getResponsiveFontSize(20),
            fontWeight: FontWeight.bold,
            color: darkTextMain,
          ),
          headlineSmall: TextStyle(
            fontSize: getResponsiveFontSize(18),
            fontWeight: FontWeight.bold,
            color: darkTextMain,
          ),
          titleLarge: TextStyle(
            fontSize: getResponsiveFontSize(20),
            fontWeight: FontWeight.bold,
            color: darkTextMain,
          ),
          titleMedium: TextStyle(
            fontSize: getResponsiveFontSize(16),
            fontWeight: FontWeight.bold,
            color: darkTextMain,
          ),
          titleSmall: TextStyle(
            fontSize: getResponsiveFontSize(14),
            fontWeight: FontWeight.bold,
            color: darkTextMain,
          ),
          bodyLarge: TextStyle(
            fontSize: getResponsiveFontSize(16),
            fontWeight: FontWeight.w500,
            color: darkTextMain,
          ),
          bodyMedium: TextStyle(
            fontSize: getResponsiveFontSize(14),
            fontWeight: FontWeight.w500,
            color: darkTextSub,
          ),
          bodySmall: TextStyle(
            fontSize: getResponsiveFontSize(12),
            fontWeight: FontWeight.normal,
            color: darkTextSub,
          ),
          labelLarge: TextStyle(
            fontSize: getResponsiveFontSize(14),
            fontWeight: FontWeight.bold,
            color: darkTextMain,
          ),
          labelSmall: TextStyle(
            fontSize: getResponsiveFontSize(12),
            fontWeight: FontWeight.bold,
            color: darkTextSub,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(getResponsiveRadius(24))),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(getResponsiveRadius(24))),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: getResponsiveWidth(24),
          vertical: getResponsiveHeight(16),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(getResponsiveRadius(24)),
          borderSide: BorderSide(color: darkSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(getResponsiveRadius(24)),
          borderSide: BorderSide(color: darkSurface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(getResponsiveRadius(24)),
          borderSide:
              BorderSide(color: darkPrimary, width: getResponsiveWidth(2)),
        ),
        hintStyle:
            TextStyle(color: darkTextSub, fontSize: getResponsiveFontSize(14)),
      ),
      iconTheme:
          IconThemeData(color: darkPrimary, size: getResponsiveFontSize(24)),
    );
  }

  // Responsive Helper Methods
  // These methods can be used for responsive calculations based on design size (390x844)
  static double getResponsiveWidth(double width) {
    final screenWidth =
        ui.PlatformDispatcher.instance.views.first.physicalSize.width /
            ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    return (width / 390.0) * screenWidth;
  }

  static double getResponsiveHeight(double height) {
    final screenHeight =
        ui.PlatformDispatcher.instance.views.first.physicalSize.height /
            ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    return (height / 844.0) * screenHeight;
  }

  static double getResponsiveFontSize(double fontSize) {
    final screenWidth =
        ui.PlatformDispatcher.instance.views.first.physicalSize.width /
            ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    return (fontSize / 390.0) * screenWidth;
  }

  static double getResponsiveRadius(double radius) {
    final screenWidth =
        ui.PlatformDispatcher.instance.views.first.physicalSize.width /
            ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    return (radius / 390.0) * screenWidth;
  }
}
