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
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Centered Title
        Container(
          margin: EdgeInsets.symmetric(horizontal: 60.w(context)),
          child: Text(
            AppStrings.reviewTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp(context),
              color: AppColors.textMain,
            ),
          ),
        ),

        // Cancel Button (Far Right / Start)
        Positioned.directional(
          textDirection: Directionality.of(context),
          start: 0,
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding:
                  EdgeInsets.zero, // Remove internal padding to hit the edge
              minimumSize: Size(44.w(context), 44.h(context)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: AlignmentDirectional.centerStart,
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
    );
  }
}
