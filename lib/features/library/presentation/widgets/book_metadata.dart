import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class BookMetadata extends StatelessWidget {
  final List<String> tags;

  const BookMetadata({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w(context),
      children: tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w(context), vertical: 8.h(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          child: Text(
            tag,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.primaryBlue),
          ),
        );
      }).toList(),
    );
  }
}
