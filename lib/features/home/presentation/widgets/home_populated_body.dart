import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/main_navigation_screen.dart';
import '../../domain/entities/home_entity.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/presentation/pages/book_details_page.dart';
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
                onPressed: () {
                  // Navigate to library tab with "Reading" filter
                  final mainNavState = context.findAncestorStateOfType<State<MainNavigationScreen>>();
                  if (mainNavState != null && mainNavState.mounted) {
                    // Call the public changeTab method with library tab filter
                    (mainNavState as dynamic).changeTab(1, libraryTab: AppStrings.tabReading);
                  }
                },
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
                final homeBook = data.currentlyReading[index];
                return BookCard(
                  book: homeBook,
                  onTap: () {
                    // Find the book in library by title and author
                    final libraryState = context.read<LibraryCubit>().state;
                    BookEntity? bookEntity;
                    
                    if (libraryState is LibraryLoaded) {
                      try {
                        bookEntity = libraryState.books.firstWhere(
                          (book) =>
                              book.title == homeBook.title &&
                              book.author == homeBook.author,
                        );
                      } catch (e) {
                        // Book not found in library, skip navigation
                        return;
                      }
                    } else {
                      // Library not loaded, skip navigation
                      return;
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailsPage(book: bookEntity!),
                      ),
                    ).then((_) {
                      // Refresh home data when coming back
                      if (context.mounted) {
                        // The BlocListener in home_page will handle the refresh
                      }
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
