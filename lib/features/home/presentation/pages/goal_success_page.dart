import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class GoalSuccessPage extends StatelessWidget {
  final int completedBooks;
  final int annualGoal;

  const GoalSuccessPage({
    super.key,
    required this.completedBooks,
    required this.annualGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Congratulations Animation (background)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Lottie.asset(
                'assets/lottie/Congratulations.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Confetti Animation
                  Center(
                    child: Lottie.asset(
                      'assets/lottie/Confetti.json',
                      width: 250.w(context),
                      height: 250.h(context),
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 24.h(context)),

                  // Success Title
                  Text(
                    'مبروك! 🎉',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 28.sp(context),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Achievement Message
                  Text(
                    'أنجزت هدفك السنوي للقراءة!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 17.sp(context),
                      color: AppColors.textSub,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 32.h(context)),

                  // Stats Container
                  Container(
                    padding: EdgeInsets.all(24.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20.r(context)),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Books Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              color: AppColors.primaryBlue,
                              size: 32.sp(context),
                            ),
                            SizedBox(width: 16.w(context)),
                            Text(
                              '$completedBooks',
                              style: GoogleFonts.tajawal(
                                fontSize: 48.sp(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h(context)),
                        Text(
                          'كتاب مكتمل في ${DateTime.now().year}',
                          style: GoogleFonts.tajawal(
                            fontSize: 16.sp(context),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h(context)),

                  // Congratulations Message
                  Text(
                    'أنت قارئ ملتزم ومتميز! 📚\nاستمر في رحلتك القرائية الرائعة',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 16.sp(context),
                      color: AppColors.textSub,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: 56.h(context)),

                  // Primary Button
                  _buildGradientButton(
                    context: context,
                    label: 'رائع!',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

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

