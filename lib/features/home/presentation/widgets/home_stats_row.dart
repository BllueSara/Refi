import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
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
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.format_list_numbered,
            value: "${data.totalQuotes}",
            label: AppStrings.totalQuotes,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.local_offer,
            value: "#${data.topTag}",
            label: AppStrings.topCategory,
            isHighlight: true,
          ),
        ),
      ],
    );
  }
}
