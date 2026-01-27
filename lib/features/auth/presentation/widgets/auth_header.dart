import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/utils/responsive_utils.dart';

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
          width: 80.w(context),
          height: 80.h(context),
          decoration: BoxDecoration(
            gradient: AppColors.refiMeshGradient,
            borderRadius: BorderRadius.circular(20.r(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20.r(context),
                offset: Offset(0, 10.h(context)),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r(context)),
            child: Image.asset(
              'assets/images/native_splash.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 24.h(context)),
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h(context)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp(context),
            color: AppColors.textSub,
            ////fontFamily: 'Tajawal',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: bottomSpacing.h(context)),
      ],
    );
  }
}
