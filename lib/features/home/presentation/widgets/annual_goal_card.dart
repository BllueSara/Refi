import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/scale_button.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnualGoalCard extends StatelessWidget {
  final int completedBooks;
  final int? annualGoal;
  final VoidCallback? onSetGoal;

  const AnnualGoalCard({
    super.key,
    required this.completedBooks,
    this.annualGoal,
    this.onSetGoal,
  });

  @override
  Widget build(BuildContext context) {
    // Logic: Treat 0 or null as "Not Set". Any positive number is a valid goal.
    final bool isGoalSet = annualGoal != null && annualGoal! > 0;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 180.h(context)),
      decoration: BoxDecoration(
        gradient: AppColors.refiMeshGradient, // #1E3A8A to #3B82F6
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 20.r(context),
            offset: Offset(0, 10.h(context)),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. Content
          Padding(
            padding: EdgeInsets.all(24.w(context)),
            child: isGoalSet ? _buildProgressState(context) : _buildWelcomeState(context),
          ),

          // 2. Illustration (Bottom-Left) - Only visible in Welcome State
          if (!isGoalSet)
            Positioned(
              bottom: -10.h(context),
              left: -10.w(context),
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 100.sp(context),
                  color: Colors.white,
                ),
              ),
            ),

          // 3. Edit Icon (Bottom-Left) - Only visible when goal is set
          if (isGoalSet)
            Positioned(
              bottom: 12.h(context),
              left: 12.w(context),
              child: ScaleButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSetGoal?.call();
                },
                child: Container(
                  padding: EdgeInsets.all(8.w(context)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 18.sp(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 8.h(context)),
        Text(
          "أهلاً بك في جليس! كم كتاباً تنوي ختمه في ${DateTime.now().year}؟",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp(context),
            color: Colors.white,
            height: 1.4,
          ),
        ),
        SizedBox(height: 24.h(context)),
        ScaleButton(
          onTap: () {
            HapticFeedback.mediumImpact();
            onSetGoal?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32.w(context), vertical: 14.h(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r(context)),
            ),
            child: Text(
              "حدد هدفك الآن",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp(context),
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressState(BuildContext context) {
    final goal = annualGoal!;
    // Avoid division by zero
    final safeGoal = goal == 0 ? 1 : goal;
    final progress = (completedBooks / safeGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "هدف القراءة السنوي",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp(context),
                color: Colors.white,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
              child: Text(
                "$percentage%",
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp(context),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h(context)),

        // Progress Bar
        Container(
          height: 12.h(context),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6.r(context)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10.r(context),
                          offset: Offset(0, 0),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 16.h(context)),
        Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.white70, size: 16.sp(context)),
            SizedBox(width: 8.w(context)),
            Text(
              "$completedBooks / $goal كتب مكتملة",
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontSize: 14.sp(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
