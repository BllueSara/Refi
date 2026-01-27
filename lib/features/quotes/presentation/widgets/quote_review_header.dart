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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w(context),
                vertical: 8.h(context),
              ),
            ),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: AppColors.textSub,
                fontSize: 15.sp(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            AppStrings.reviewTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp(context),
              color: AppColors.textMain,
            ),
          ),
          SizedBox(width: 70.w(context)), // Balance for cancel button
        ],
      ),
    );
  }
}
