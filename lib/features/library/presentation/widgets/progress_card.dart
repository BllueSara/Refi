import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/book_details/book_details_state.dart';

class ProgressCard extends StatelessWidget {
  final BookDetailsState state;
  final VoidCallback onUpdatePressed;

  const ProgressCard({
    super.key,
    required this.state,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15.r(context),
            offset: Offset(0, 5.h(context)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "تقدم القراءة", // Can assume localized logic or pass string
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "${state.percentage}%",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r(context)),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 10.h(context),
              backgroundColor: AppColors.inputBorder,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "صفحة ${state.currentPage} من ${state.totalPages}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPlaceholder,
                ),
              ),
              InkWell(
                onTap: onUpdatePressed,
                borderRadius: BorderRadius.circular(8.r(context)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w(context),
                    vertical: 4.h(context),
                  ),
                  child: Text(
                    "تحديث",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
