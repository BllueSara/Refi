import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/home_entity.dart';
import 'stat_card.dart';

class HomeStatsRow extends StatelessWidget {
  final HomeData data;

  const HomeStatsRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.auto_stories,
            value: "${data.completedBooks}",
            label: AppStrings.booksCompleted,
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: StatCard(
            icon: Icons.format_list_numbered,
            value: "${data.totalQuotes}",
            label: AppStrings.totalQuotes,
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: StatCard(
            icon: Icons.hourglass_empty_rounded,
            value:
                "${((data.annualGoal ?? 0) - data.completedBooks).clamp(0, 999)}",
            label: "كتب بانتظارك",
            isHighlight: true,
          ),
        ),
      ],
    );
  }
}
