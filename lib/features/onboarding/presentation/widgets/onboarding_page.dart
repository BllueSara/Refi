import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/utils/responsive_utils.dart';

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
      padding: EdgeInsets.all(AppSizes.p24.w(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Container
          Container(
            height: 300.h(context),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                AppSizes.buttonRadius.r(context),
              ), // Using buttonRadius (24) as per design consistency
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
              child: SvgPicture.string(svgString, fit: BoxFit.contain),
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
