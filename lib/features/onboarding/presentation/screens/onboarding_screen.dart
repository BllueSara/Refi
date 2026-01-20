import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/onboarding_skip_button.dart';
import '../widgets/onboarding_navigation_controls.dart';
import '../constants/onboarding_svgs.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';

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
      // Completed - Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onSkipTap(BuildContext context) {
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
                    children: const [
                      OnboardingPage(
                        svgString: OnboardingSvgs.digitalShelf,
                        title: AppStrings.onboardingTitle1,
                        bodyText: AppStrings.onboardingBody1,
                      ),
                      OnboardingPage(
                        svgString: OnboardingSvgs.smartScan,
                        title: AppStrings.onboardingTitle2,
                        bodyText: AppStrings.onboardingBody2,
                      ),
                      OnboardingPage(
                        svgString: OnboardingSvgs.savedIdeas,
                        title: AppStrings.onboardingTitle3,
                        bodyText: AppStrings.onboardingBody3,
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
