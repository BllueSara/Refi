import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/home_entity.dart';
import 'book_card.dart';
import 'home_hero_quote.dart';
import 'home_stats_row.dart';

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
          HomeHeroQuote(
            quote: data.dailyQuote ?? "",
            author: data.dailyQuoteAuthor ?? "",
          ),

          const SizedBox(height: 32),

          // Stats Label
          const Text(
            "إحصائياتك",
            style: TextStyle(
              //fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          HomeStatsRow(data: data),

          const SizedBox(height: 32),

          // Currently Reading Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.currentlyReading,
                style: TextStyle(
                  //fontFamily: 'Tajawal',
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
                    //fontFamily: 'Tajawal',
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
