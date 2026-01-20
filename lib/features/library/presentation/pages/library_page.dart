import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../cubit/library_cubit.dart'; // Add Cubit Import
import '../widgets/library_empty_view.dart';
import '../widgets/library_book_card.dart';
import 'book_details_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // Tabs
  final List<String> _tabs = [
    AppStrings.tabAll,
    AppStrings.tabReading,
    AppStrings.tabCompleted,
    AppStrings.tabWishlist,
  ];

  @override
  Widget build(BuildContext context) {
    // Provide Cubit
    return BlocProvider(
      create: (context) => LibraryCubit()
        ..loadLibrary(
          isEmpty: false,
        ), // Set isEmpty: false to test populated state
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.textMain,
              size: 28,
            ), // Matches upload image_1 header
            onPressed: () {
              // Add book action
            },
          ),
          centerTitle: true,
          title: const Text(
            AppStrings.libraryTitle,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textMain,
            ),
          ),
          automaticallyImplyLeading:
              false, // Don't show back button on main tab
        ),
        body: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            } else if (state is LibraryEmpty) {
              return const LibraryEmptyView();
            } else if (state is LibraryLoaded) {
              return Column(
                children: [
                  // Tabs
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        final isActive = state.activeTab == tab;
                        return GestureDetector(
                          onTap: () {
                            context.read<LibraryCubit>().filterBooks(tab);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? AppColors.refiMeshGradient
                                  : null,
                              color: isActive ? null : AppColors.inputBorder,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textSub,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Grid
                  Expanded(
                    child: state.filteredBooks.isEmpty
                        ? Center(
                            child: Text(
                              "لا توجد كتب",
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                color: AppColors.textSub,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio:
                                      0.65, // Adjust based on card height
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 24,
                                ),
                            itemCount: state.filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = state.filteredBooks[index];
                              return LibraryBookCard(
                                book: book,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookDetailsPage(
                                        bookTitle: book.title,
                                        author: book.author,
                                        currentPage: book.currentPage,
                                        totalPages: book.totalPages,
                                        tags: book.tags,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
