import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color white = Colors.white;
  static const Color background = Colors.white;

  static const Color textMain = Colors.black87;
  static const Color textSub = Color(0xFF64748B); // Slate 500
  static const Color textPlaceholder = Color(0xFF94A3B8); // Slate 400
  static const Color inactiveDot = Color(0xFFE2E8F0); // Slate 200

  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);

  static const Color inputBorder = Color(0xFFF1F5F9);

  static const LinearGradient refiMeshGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
