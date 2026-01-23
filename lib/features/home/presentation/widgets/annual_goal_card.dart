import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/scale_button.dart';
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
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        gradient: AppColors.refiMeshGradient, // #1E3A8A to #3B82F6
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: isGoalSet ? _buildProgressState() : _buildWelcomeState(),
          ),

          // 2. Illustration (Bottom-Left) - Only visible in Welcome State
          if (!isGoalSet)
            Positioned(
              bottom: -10,
              left: -10,
              child: Opacity(
                opacity: 0.15,
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),

          // 3. Edit Icon (Bottom-Left) - Only visible when goal is set
          if (isGoalSet)
            Positioned(
              bottom: 12,
              left: 12,
              child: ScaleButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSetGoal?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Text(
          "أهلاً بك في جليس! كم كتاباً تنوي ختمه في ${DateTime.now().year}؟",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ScaleButton(
          onTap: () {
            HapticFeedback.mediumImpact();
            onSetGoal?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "حدد هدفك الآن",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressState() {
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
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$percentage%",
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress Bar
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Text(
              "$completedBooks / $goal كتب مكتملة",
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
