import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import '../constants/colors.dart';
import '../utils/responsive_utils.dart';

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
            top: MediaQuery.of(context).padding.top + 16.h(context),
            right: 20.w(context),
            child: IconButton(
              icon: Icon(Icons.close,
                  color: AppColors.textSub, size: 28.sp(context)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie Animation Container - Perfectly Centered
                  Container(
                    width: 260.w(context),
                    height: 260.h(context),
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
                  SizedBox(height: 48.h(context)),

                  // Success Message - Tajawal Extra Bold
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 28.sp(context),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 17.sp(context),
                      color: AppColors.textSub,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 56.h(context)),

                  // Primary Action (Refi Mesh Gradient Button)
                  _buildGradientButton(
                    context: context,
                    label: primaryButtonLabel,
                    onTap: onPrimaryAction,
                  ),

                  // Secondary Action
                  if (secondaryButtonLabel != null &&
                      onSecondaryAction != null) ...[
                    SizedBox(height: 20.h(context)),
                    TextButton(
                      onPressed: onSecondaryAction,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h(context), horizontal: 32.w(context)),
                      ),
                      child: Text(
                        secondaryButtonLabel!,
                        style: GoogleFonts.tajawal(
                          fontSize: 16.sp(context),
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
      height: 60.h(context),
      decoration: BoxDecoration(
        gradient: AppColors.refiMeshGradient,
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20.r(context),
            offset: Offset(0, 10.h(context)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r(context)),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 18.sp(context),
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
