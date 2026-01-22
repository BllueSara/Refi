import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const OnboardingSkipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        AppStrings.skip,
        style: TextStyle(
          color: AppColors.textSub,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          // //fontFamily: 'Tajawal',
        ),
      ),
    );
  }
}
