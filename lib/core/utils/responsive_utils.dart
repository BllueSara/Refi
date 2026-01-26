import 'package:flutter/material.dart';

/// Utility class for responsive sizing that replaces ScreenUtil
/// Uses MediaQuery to calculate responsive dimensions based on design size
class ResponsiveUtil {
  // Design size used in ScreenUtilInit (390, 844)
  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  /// Get responsive width based on design width
  static double width(BuildContext context, double width) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return (width / designWidth) * screenWidth;
  }

  /// Get responsive height based on design height
  static double height(BuildContext context, double height) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    return (height / designHeight) * screenHeight;
  }

  /// Get responsive font size based on design width
  static double fontSize(BuildContext context, double fontSize) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return (fontSize / designWidth) * screenWidth;
  }

  /// Get responsive radius based on design width
  static double radius(BuildContext context, double radius) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return (radius / designWidth) * screenWidth;
  }
}

/// Extension methods for easier usage (similar to ScreenUtil's .w, .h, .sp, .r)
extension ResponsiveExtension on num {
  /// Responsive width (equivalent to .w in ScreenUtil)
  double w(BuildContext context) {
    return ResponsiveUtil.width(context, toDouble());
  }

  /// Responsive height (equivalent to .h in ScreenUtil)
  double h(BuildContext context) {
    return ResponsiveUtil.height(context, toDouble());
  }

  /// Responsive font size (equivalent to .sp in ScreenUtil)
  double sp(BuildContext context) {
    return ResponsiveUtil.fontSize(context, toDouble());
  }

  /// Responsive radius (equivalent to .r in ScreenUtil)
  double r(BuildContext context) {
    return ResponsiveUtil.radius(context, toDouble());
  }
}
