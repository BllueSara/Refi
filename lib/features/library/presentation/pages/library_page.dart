import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/book_entity.dart';
import '../widgets/library_skeleton.dart';
import '../cubit/library_cubit.dart';
import '../widgets/library_empty_view.dart';
import '../widgets/library_book_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../add_book/presentation/screens/search_screen.dart';
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

  String _activeTab = AppStrings.tabAll;

  List<BookEntity> _filterBooks(List<BookEntity> books) {
    if (_activeTab == AppStrings.tabAll) {
      return books;
    }
    if (_activeTab == AppStrings.tabReading) {
      return books.where((b) => b.status == BookStatus.reading).toList();
    }
    if (_activeTab == AppStrings.tabCompleted) {
      return books.where((b) => b.status == BookStatus.completed).toList();
    }
    if (_activeTab == AppStrings.tabWishlist) {
      return books.where((b) => b.status == BookStatus.wishlist).toList();
    }
    return books;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.add_circle,
            color: AppColors.textMain,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ).then((_) {
              if (context.mounted) {
                context.read<LibraryCubit>().loadLibrary();
              }
            });
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
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return const LibrarySkeleton();
          } else if (state is LibraryEmpty) {
            return const LibraryEmptyView();
          } else if (state is LibraryError) {
            return Center(child: Text(state.message));
          } else if (state is LibraryLoaded) {
            final filteredBooks = _filterBooks(state.books);

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
                      final isActive = _activeTab == tab;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeTab = tab;
                          });
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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<LibraryCubit>().loadLibrary();
                    },
                    child: filteredBooks.isEmpty
                        ? Center(
                            child: EmptyStateWidget(
                              title: "مكتبتك فارغة",
                              subtitle: "ابدأ رحلتك بإضافة كتابك الأول",
                              icon: Icons.menu_book_rounded,
                              actionLabel: "إضافة كتاب",
                              onAction: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SearchScreen(),
                                  ),
                                ).then((_) {
                                  if (context.mounted) {
                                    context.read<LibraryCubit>().loadLibrary();
                                  }
                                });
                              },
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 24,
                                ),
                            itemCount: filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];
                              return LibraryBookCard(
                                book: book,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BookDetailsPage(book: book),
                                    ),
                                  ).then((_) {
                                    // Refresh library when coming back (in case status changed)
                                    if (context.mounted) {
                                      context
                                          .read<LibraryCubit>()
                                          .loadLibrary();
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
