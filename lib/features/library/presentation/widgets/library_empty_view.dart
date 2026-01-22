import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../add_book/presentation/screens/search_screen.dart';

class LibraryEmptyView extends StatelessWidget {
  const LibraryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shelf Illustration Placeholder
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simple custom paint or icon for "Shelf"
                Icon(
                  Icons.shelves,
                  size: 100,
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                ),
                const Positioned(
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            AppStrings.libraryEmptyTitle,
            style: TextStyle(
              //fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              AppStrings.libraryEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontSize: 14,
                color: AppColors.textSub,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.refiMeshGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                AppStrings.libraryAddBookNow,
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
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
