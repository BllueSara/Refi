import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double bottomSpacing;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.bottomSpacing = AppSizes.p32,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Container (Gradient Mesh Look)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.refiMeshGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/native_splash.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSub,
            //fontFamily: 'Tajawal',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}
