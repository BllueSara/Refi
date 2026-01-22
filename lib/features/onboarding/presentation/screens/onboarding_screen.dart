import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../cubit/onboarding_cubit.dart';

import '../widgets/onboarding_skip_button.dart';
import '../widgets/onboarding_navigation_controls.dart';
import '../widgets/onboarding_lottie_page.dart';

import '../../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextTap(BuildContext context, OnboardingCubit cubit) {
    if (cubit.state < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Completed - Navigate to Login
      context.read<AuthCubit>().setOnboardingSeen();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onSkipTap(BuildContext context) {
    context.read<AuthCubit>().setOnboardingSeen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leadingWidth: 80,
          leading: Builder(
            builder: (context) {
              return OnboardingSkipButton(onTap: () => _onSkipTap(context));
            },
          ),
          actions: const [SizedBox(width: AppSizes.p16)],
        ),
        body: BlocBuilder<OnboardingCubit, int>(
          builder: (context, currentIndex) {
            return Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      context.read<OnboardingCubit>().pageChanged(index);
                    },
                    children: [
                      _AnimatedOnboardingWrapper(
                        isActive: currentIndex == 0,
                        child: OnboardingLottiePage(
                          lottieAssetPath: 'assets/images/books.json',
                          title: AppStrings.onboardingTitle1,
                          bodyText: AppStrings.onboardingBody1,
                          // Fallback: Blue Fill, White Stroke
                          delegates: LottieDelegates(
                            values: [
                              ValueDelegate.color([
                                '**',
                                'Stroke 1',
                                '**',
                              ], value: Colors.white),
                              ValueDelegate.color([
                                '**',
                                'Fill 1',
                                '**',
                              ], value: AppColors.primaryBlue),
                            ],
                          ),
                        ),
                      ),
                      _AnimatedOnboardingWrapper(
                        isActive: currentIndex == 1,
                        child: OnboardingLottiePage(
                          lottieAssetPath: 'assets/images/Quotation.json',
                          title: AppStrings.onboardingTitle2,
                          bodyText: AppStrings.onboardingBody2,
                          // Config: Bright Blue Card (Secondary), Deep Blue Details (Primary)
                          gradientBackground: false,
                          delegates: LottieDelegates(
                            values: [
                              // Lines (Strokes) -> Primary Blue (Dark)
                              ValueDelegate.strokeColor([
                                '**',
                                'Stroke 1',
                                '**',
                              ], value: AppColors.secondaryBlue),
                              // Fills -> Card (Secondary) vs Quotes (Primary)
                              ValueDelegate.color(
                                ['**', 'Fill 1', '**'],
                                callback: (frameInfo) {
                                  final Color? original = frameInfo.startValue;
                                  if (original != null) {
                                    // If light (Card Background) -> Secondary Blue (Bright)
                                    if (original.computeLuminance() > 0.5) {
                                      return AppColors.secondaryBlue;
                                    }
                                    // If dark (Quotes) -> Primary Blue (Dark)
                                    return AppColors.primaryBlue;
                                  }
                                  return Colors.transparent;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      _AnimatedOnboardingWrapper(
                        isActive: currentIndex == 2,
                        child: OnboardingLottiePage(
                          lottieAssetPath: 'assets/images/Creativity.json',
                          title: AppStrings.onboardingTitle3,
                          bodyText: AppStrings.onboardingBody3,
                          delegates: LottieDelegates(
                            values: [
                              // Creativity: Replace Yellow with Brand Blue
                              // Stroke -> Primary Blue for consistency
                              ValueDelegate.color([
                                '**',
                                'Kontur 1',
                                '**',
                              ], value: AppColors.primaryBlue),
                              // Fill -> Replace Yellow only (Targeting both possible encodings)
                              ValueDelegate.color(
                                ['**', 'Fläche 1', '**'],
                                callback: (frameInfo) {
                                  final Color? original = frameInfo.startValue;
                                  if (original != null) {
                                    if (original.red > 200 &&
                                        original.green > 150 &&
                                        original.blue < 100) {
                                      return AppColors.primaryBlue;
                                    }
                                  }
                                  return original ?? Colors.transparent;
                                },
                              ),
                              ValueDelegate.color(
                                ['**', 'FlÃ¤che 1', '**'],
                                callback: (frameInfo) {
                                  final Color? original = frameInfo.startValue;
                                  if (original != null) {
                                    // Check for Yellow
                                    if (original.red > 200 &&
                                        original.green > 150 &&
                                        original.blue < 100) {
                                      return AppColors.primaryBlue;
                                    }
                                  }
                                  return original ?? Colors.transparent;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Extracted Navigation Controls
                OnboardingNavigationControls(
                  pageController: _pageController,
                  currentIndex: currentIndex,
                  onNextTap: () =>
                      _onNextTap(context, context.read<OnboardingCubit>()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedOnboardingWrapper extends StatelessWidget {
  final bool isActive;
  final Widget child;

  const _AnimatedOnboardingWrapper({
    required this.isActive,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      opacity: isActive ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCubic,
        offset: isActive ? Offset.zero : const Offset(-0.2, 0),
        child: child,
      ),
    );
  }
}
