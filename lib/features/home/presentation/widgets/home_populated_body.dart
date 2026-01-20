import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/home_entity.dart';
import 'stat_card.dart';
import 'book_card.dart';

class HomePopulatedBody extends StatelessWidget {
  final HomeData data;

  const HomePopulatedBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Quote Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.refiMeshGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: Colors.white70,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  data.dailyQuote ?? "",
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Share Icon (Left in RTL, which is End) -> Actually prompt says "Share icon in bottom-left".
                    // In RTL, Start is Right, End is Left. So we want End.
                    // But typically Share is an action. Let's put it at the end (left).
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Text(
                      data.dailyQuoteAuthor ?? "",
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Stats Label
          const Text(
            "إحصائياتك", // Or make it a string
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid (3 cards)
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.auto_stories, // Book icon
                  value: "${data.completedBooks}", // "14"
                  label: AppStrings.booksCompleted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.format_list_numbered,
                  value: "${data.totalQuotes}", // "128"
                  label: AppStrings.totalQuotes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.local_offer,
                  value: "#${data.topTag}", // "#Adab"
                  label: AppStrings.topCategory,
                  isHighlight: true, // Maybe distinct style
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Currently Reading Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.currentlyReading,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textMain,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  AppStrings.viewAll,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Currently Reading List
          SizedBox(
            height: 140, // Adjust height for list
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.currentlyReading.length,
              itemBuilder: (context, index) {
                return BookCard(book: data.currentlyReading[index]);
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
