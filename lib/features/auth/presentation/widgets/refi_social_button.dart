import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../core/utils/responsive_utils.dart';

class RefiSocialButton extends StatelessWidget {
  final String label;
  final Widget icon; // Can be Icon or SvgPicture
  final VoidCallback onTap;

  const RefiSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r(context)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12.h(context),
          horizontal: AppSizes.p16.w(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r(context)),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 12.w(context)),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                ////fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
