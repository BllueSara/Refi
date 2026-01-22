import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_strings.dart';
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
          AnimatedSlide(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            offset: const Offset(0, 0.04),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              opacity: 1,
              child: Container(
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
                      borderRadius: BorderRadius.circular(
                        AppSizes.buttonRadius,
                      ),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation =
                          Tween<Offset>(
                            begin: const Offset(0.08, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          );

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: currentIndex < 2
                        ? Row(
                            key: const ValueKey('next'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                AppStrings.next,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                  //fontFamily: 'Tajawal',
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons
                                    .arrow_forward, // Mirrors to point Left in RTL (Next)
                                color: AppColors.white,
                              ),
                            ],
                          )
                        : const Text(
                            key: ValueKey('start'),
                            AppStrings.startJourney,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              //fontFamily: 'Tajawal',
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
