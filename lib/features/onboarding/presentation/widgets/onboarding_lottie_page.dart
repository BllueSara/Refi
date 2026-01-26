import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/utils/responsive_utils.dart';

class OnboardingLottiePage extends StatelessWidget {
  final String lottieAssetPath;
  final String title;
  final String bodyText;
  final LottieDelegates? delegates;
  final bool gradientObjects;
  final bool gradientBackground;

  const OnboardingLottiePage({
    super.key,
    required this.lottieAssetPath,
    required this.title,
    required this.bodyText,
    this.delegates,
    this.gradientObjects = false,
    this.gradientBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.p24.w(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Container
          Container(
            height: 300.h(context),
            width: double.infinity,
            decoration: BoxDecoration(
              // If gradientBackground is true, use the mesh gradient.
              gradient: gradientBackground ? AppColors.refiMeshGradient : null,
              // If no gradient, use white.
              color: gradientBackground ? null : AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius.r(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20.r(context),
                  offset: Offset(0, 10.h(context)),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius.r(context)),
              child: Lottie.asset(
                lottieAssetPath,
                fit: BoxFit.contain,
                delegates: delegates,
              ),
            ),
          ),
          SizedBox(height: AppSizes.p48.h(context)),

          // Headline
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: AppSizes.p16.h(context)),

          // Body
          Text(
            bodyText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSub,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
