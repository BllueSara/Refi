import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';

class OnboardingPage extends StatelessWidget {
  final String svgString;
  final String title;
  final String bodyText;

  const OnboardingPage({
    super.key,
    required this.svgString,
    required this.title,
    required this.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Container
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                AppSizes.buttonRadius,
              ), // Using buttonRadius (24) as per design consistency
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              child: SvgPicture.string(svgString, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: AppSizes.p48),

          // Headline
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: AppSizes.p16),

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
