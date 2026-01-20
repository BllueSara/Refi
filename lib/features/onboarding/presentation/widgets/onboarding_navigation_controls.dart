import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';

class OnboardingNavigationControls extends StatelessWidget {
  final PageController pageController;
  final VoidCallback onNextTap;
  final int currentIndex;

  const OnboardingNavigationControls({
    super.key,
    required this.pageController,
    required this.onNextTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        children: [
          // Dots
          SmoothPageIndicator(
            controller: pageController,
            count: 3,
            effect: const ExpandingDotsEffect(
              activeDotColor: AppColors.primaryBlue,
              dotColor: AppColors.inactiveDot,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 4,
              spacing: 8,
            ),
          ),
          const SizedBox(height: AppSizes.p32),

          // Dynamic Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.refiMeshGradient,
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            ),
            child: ElevatedButton(
              onPressed: onNextTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentIndex < 2) ...[
                    const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                    ), // RTL Arrow pointing left
                    const SizedBox(width: 8),
                    const Text(
                      AppStrings.next,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ] else
                    const Text(
                      AppStrings.startJourney,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
