import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class BookMetadata extends StatelessWidget {
  final List<String> tags;

  const BookMetadata({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
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
