import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import '../constants/colors.dart';

class RefiSuccessWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryAction;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryAction;

  const RefiSuccessWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryButtonLabel,
    required this.onPrimaryAction,
    this.secondaryButtonLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Close button at top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSub, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie Animation Container - Perfectly Centered
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Lottie.asset(
                        'assets/images/Success.json',
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Success Message - Tajawal Extra Bold
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 17,
                      color: AppColors.textSub,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 56),

                  // Primary Action (Refi Mesh Gradient Button)
                  _buildGradientButton(
                    context: context,
                    label: primaryButtonLabel,
                    onTap: onPrimaryAction,
                  ),

                  // Secondary Action
                  if (secondaryButtonLabel != null &&
                      onSecondaryAction != null) ...[
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: onSecondaryAction,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 32),
                      ),
                      child: Text(
                        secondaryButtonLabel!,
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSub,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.refiMeshGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
