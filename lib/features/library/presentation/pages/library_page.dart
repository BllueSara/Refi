import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final String? initialTab;

  const LibraryPage({super.key, this.initialTab});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // Tabs
  final List<String> _tabs = [
    AppStrings.tabAll,
    AppStrings.tabWishlist,
    AppStrings.tabReading,
    AppStrings.tabCompleted,
  ];

  late String _activeTab;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use initialTab if provided, otherwise default to "All"
    _activeTab = widget.initialTab ?? AppStrings.tabAll;
  }

  @override
  void didUpdateWidget(LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update active tab if initialTab changed
    if (widget.initialTab != null &&
        widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _activeTab = widget.initialTab!;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookEntity> _filterBooks(List<BookEntity> books) {
    List<BookEntity> filtered = books;

    // Filter by tab
    if (_activeTab == AppStrings.tabReading) {
      filtered = filtered.where((b) => b.status == BookStatus.reading).toList();
    } else if (_activeTab == AppStrings.tabCompleted) {
      filtered =
          filtered.where((b) => b.status == BookStatus.completed).toList();
    } else if (_activeTab == AppStrings.tabWishlist) {
      filtered =
          filtered.where((b) => b.status == BookStatus.wishlist).toList();
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((book) {
        final titleMatch = book.title.toLowerCase().contains(query);
        final authorMatch = book.authors.any(
          (author) => author.toLowerCase().contains(query),
        );
        return titleMatch || authorMatch;
      }).toList();
    }

    // --- Priority Sorting Protocol ---
    // Top: Reading now (High progress first) - 0 < progress < 100% (Descending)
    // Middle: Not started (0% progress)
    // Bottom: Finished (100% progress)
    filtered.sort((a, b) {
      final aP = a.progressPercentage;
      final bP = b.progressPercentage;

      final aFinished = aP >= 100;
      final bFinished = bP >= 100;
      final aReading = aP > 0 && aP < 100;
      final bReading = bP > 0 && bP < 100;
      final aNotStarted = aP == 0;
      final bNotStarted = bP == 0;

      // 1. Finished books go to bottom
      if (aFinished && !bFinished) return 1;
      if (!aFinished && bFinished) return -1;
      if (aFinished && bFinished) return 0; // Both finished, maintain order

      // 2. Reading books (with progress) come before not started
      if (aReading && bNotStarted) return -1;
      if (aNotStarted && bReading) return 1;

      // 3. Both reading: Sort by progress descending (high progress first)
      if (aReading && bReading) {
        return bP.compareTo(aP); // 90% before 10%
      }

      // 4. Both not started: Maintain order
      if (aNotStarted && bNotStarted) {
        return 0;
      }

      return 0;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          AppStrings.libraryTitle,
          style: TextStyle(
            //fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textMain,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<LibraryCubit, LibraryState>(
        listener: (context, state) {
          // Listen to state changes to ensure UI updates
          // This ensures the page rebuilds when books are added/updated/deleted
        },
        child: BlocBuilder<LibraryCubit, LibraryState>(
          buildWhen: (previous, current) {
            // Always rebuild when state changes
            return true;
          },
          builder: (context, state) {
          if (state is LibraryLoading) {
            return const LibrarySkeleton();
          } else if (state is LibraryEmpty) {
            return LibraryEmptyView(activeTab: _activeTab);
          } else if (state is LibraryError) {
            return Center(child: Text(state.message));
          } else if (state is LibraryLoaded) {
            final filteredBooks = _filterBooks(state.books);

            return Column(
              children: [
                // Search Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchHint,
                      hintStyle: GoogleFonts.tajawal(
                        color: AppColors.textSub.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSub,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textSub,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.inputBorder,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
                // Tabs
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 16),
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
                            gradient:
                                isActive ? AppColors.refiMeshGradient : null,
                            color: isActive ? null : AppColors.inputBorder,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tab,
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              color:
                                  isActive ? Colors.white : AppColors.textSub,
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
                      await context
                          .read<LibraryCubit>()
                          .loadLibrary(forceRefresh: true);
                    },
                    child: (state.books.isEmpty)
                        ? LibraryEmptyView(activeTab: _activeTab) // No scroll needed - fits screen
                        : filteredBooks.isEmpty
                            ? Center(
                                child: Builder(
                                  builder: (context) {
                                    String title = "لا توجد نتائج";
                                    String? subtitle =
                                        "جرب البحث بكلمات مختلفة";

                                    if (_searchController.text.isEmpty) {
                                      switch (_activeTab) {
                                        case AppStrings.tabReading:
                                          title =
                                              "رفوفك الحالية فارغة.. ما هو رفيقك القادم؟";
                                          subtitle = null;
                                          break;
                                        case AppStrings.tabCompleted:
                                          title =
                                              "مكتبة الإنجازات تنتظر بطلها الأول!";
                                          subtitle = null;
                                          break;
                                        case AppStrings.tabWishlist:
                                          title =
                                              "قائمة الأمنيات فارغة، استكشف كتباً تثير فضولك.";
                                          subtitle = null;
                                          break;
                                        default:
                                          title =
                                              "لا توجد كتب في هذا القسم بعد، استمر في القراءة لملئه!";
                                          subtitle = null;
                                      }
                                    }

                                    return EmptyStateWidget(
                                      title: title,
                                      subtitle: subtitle,
                                      activeTab: _activeTab,
                                      // Add search button for wishlist tab
                                      actionLabel: _activeTab == AppStrings.tabWishlist
                                          ? "ابدأ بالبحث عن كتاب"
                                          : null,
                                      onAction: _activeTab == AppStrings.tabWishlist
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const SearchScreen(),
                                                ),
                                              );
                                            }
                                          : null,
                                    );
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
                                    activeTab: _activeTab,
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
                                              .loadLibrary(forceRefresh: true);
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
      ),
    );
  }
}
