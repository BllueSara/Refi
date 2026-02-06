import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class QuoteReviewHeader extends StatelessWidget {
  final VoidCallback onCancel;

  const QuoteReviewHeader({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered Title
          Text(
            AppStrings.reviewTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp(context),
              color: AppColors.textMain,
            ),
          ),

          // Cancel Button (Far Right / Start)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w(context),
                  vertical: 8.h(context),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: AppColors.textSub,
                  fontSize: 15.sp(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
