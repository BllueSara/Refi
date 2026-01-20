import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';

class SearchStartWidget extends StatelessWidget {
  const SearchStartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF), // Light blue tint
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.book_rounded,
                size: 64,
                color: AppColors.primaryBlue,
              ), // Revisit icon later to match image 100%
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            AppStrings.searchStartTitle,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textMain,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppStrings.searchStartBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: AppColors.textSub,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchEmptyWidget extends StatelessWidget {
  final VoidCallback onAddManually;

  const SearchEmptyWidget({super.key, required this.onAddManually});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Placeholder (Search with X)
          Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.search_off_rounded,
                size: 60,
                color: AppColors.textPlaceholder,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            AppStrings.searchNoResultsTitle,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppStrings.searchNoResultsBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: AppColors.textSub,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.refiMeshGradient,
              borderRadius: BorderRadius.circular(24), // 24px radius
            ),
            child: ElevatedButton.icon(
              onPressed: onAddManually,
              icon: const Icon(Icons.add_circle, color: Colors.white),
              label: const Text(
                AppStrings.addBookManually,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
