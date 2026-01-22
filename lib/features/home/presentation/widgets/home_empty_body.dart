import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import 'stat_card.dart';
import '../../../add_book/presentation/screens/search_screen.dart';

class HomeEmptyBody extends StatelessWidget {
  const HomeEmptyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card
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
                const Text(
                  AppStrings.startKnowledgeJourney,
                  style: TextStyle(
                    //fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.startJourneyDesc,
                  style: TextStyle(
                    //fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Currently Reading Section
          const Text(
            AppStrings.currentlyReading,
            style: TextStyle(
              //fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.textPlaceholder,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.noBooksReading,
                  style: TextStyle(
                    //fontFamily: 'Tajawal',
                    fontSize: 16,
                    color: AppColors.textSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    AppStrings.addBookFirst,
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.access_time_filled,
                  value: "-", // Placeholder
                  label: AppStrings.firstQuoteCapture, // "التقط اقتباسك الأول"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  icon: Icons.check_circle_outline,
                  value: "-",
                  label: AppStrings.booksCompleted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              AppStrings.waitingForAchievement,
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontSize: 14,
                color: AppColors.textPlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
