import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/presentation/cubit/search_cubit.dart';
import '../widgets/search_states_widgets.dart';
import 'manual_entry_screen.dart';

import '../../../../core/widgets/main_navigation_screen.dart';
import '../../../library/presentation/pages/book_details_page.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SearchCubit>(),
      child: const SearchScreenContent(),
    );
  }
}

class SearchScreenContent extends StatefulWidget {
  const SearchScreenContent({super.key});

  @override
  State<SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<SearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<SearchCubit>().search(query);
  }

  void _navigateToAddManually() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
    );
  }

  /// Step 2: The Success Screen
  void _showSuccessScreen(BuildContext context, BookEntity book) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Close Icon
              Positioned(
                top: 56, // Safe area
                right: 24,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSub),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(
                        context); // Close search screen too if desired? Or just go back to search?
                    // User request: "Button 'Back to Search' returns to search screen"
                    // So close icon likely just closes this dialog.
                  },
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hero Illustration (Festive blue book)
                    // Using Success.json or a placeholder if image not available
                    Lottie.asset(
                      'assets/images/Success.json',
                      width: 250,
                      height: 250,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "تمت إضافة الكتاب بنجاح!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "أصبح الكتاب الآن جزءاً من رحلتك المعرفية",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: AppColors.textSub,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Primary Action: Start Reading
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.refiMeshGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx); // Close Success
                            // Adding navigation to Library or BookDetails
                            // Since we don't have direct BookDetails navigation easily without context shuffle,
                            // We'll navigate back to MainNav then Library
                            Navigator.pop(context); // Close Search
                            final mainNavState =
                                context.findAncestorStateOfType<
                                    State<MainNavigationScreen>>();
                            if (mainNavState != null) {
                              (mainNavState as dynamic).changeTab(1); // Library
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "ابدأ القراءة الآن",
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Secondary Action: Back to Search
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        "العودة للبحث",
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 1: Confirmation Bottom Sheet (With Validation)
  void _showAddSheet(BookEntity book) {
    // 1. Validation Logic
    final libraryState = context.read<LibraryCubit>().state;
    BookEntity? existingBook;

    if (libraryState is LibraryLoaded) {
      try {
        existingBook = libraryState.books.firstWhere(
          (b) =>
              b.title == book.title &&
              b.authors.firstOrNull == book.authors.firstOrNull,
        );
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        // If book exists, show "Already in Library" View
        if (existingBook != null) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        image: book.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(book.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[200],
                      ),
                      child: book.imageUrl == null
                          ? const Icon(Icons.book, size: 50, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "هذا الكتاب موجود بالفعل في مكتبتك",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.refiMeshGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx); // Close Sheet
                            // Navigate to Book Details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailsPage(book: existingBook!),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "انتقل إلى الكتاب في مكتبتي",
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        "إغلاق",
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          color: AppColors.textSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Standard Add Sheet
        return StatefulBuilder(
          builder: (context, setState) {
            BookStatus selectedStatus = BookStatus.reading;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Book Cover
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: book.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(book.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[200],
                        ),
                        child: book.imageUrl == null
                            ? const Icon(Icons.book,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Title & Subtitle
                      Text(
                        "هل تود إضافة هذا الكتاب؟",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "سيتم حفظ الكتاب في قائمة كتبك الخاصة",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: AppColors.textSub,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Status Selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<BookStatus>(
                            value: selectedStatus,
                            isExpanded: true,
                            icon: const Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: AppColors.primaryBlue),
                            onChanged: (BookStatus? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: BookStatus.reading,
                                child: Text(
                                  "أقرأه الآن",
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    color: AppColors.textMain,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BookStatus.completed,
                                child: Text(
                                  "مكتمل",
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    color: AppColors.textMain,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BookStatus.wishlist,
                                child: Text(
                                  "سأقرأه لاحقاً",
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    color: AppColors.textMain,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Primary Action
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.refiMeshGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx); // Close Sheet first

                              // Perform Add Logic
                              await context.read<LibraryCubit>().addBook(
                                  book.copyWith(status: selectedStatus));

                              // Trigger Success Screen
                              if (context.mounted) {
                                _showSuccessScreen(context, book);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "إضافة إلى مكتبتي",
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Secondary Action
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          "إلغاء",
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: AppColors.textSub,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(),
        leadingWidth: 0,
        title: Text(
          "بحث",
          style: GoogleFonts.tajawal(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Search Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      textAlign: TextAlign.right,
                      onChanged: _onSearchChanged,
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "ابن خلدون",
                        hintStyle: GoogleFonts.tajawal(color: Colors.grey),
                        suffixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sub-header
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // RTL align right
                      children: [
                        Text(
                          "نتائج البحث",
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey, // textSub
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Results
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return const SearchStartWidget();
                    } else if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SearchError) {
                      return Center(
                          child: Text(state.message,
                              style: GoogleFonts.tajawal()));
                    } else if (state is SearchSuccess) {
                      if (state.books.isEmpty) {
                        return SearchEmptyWidget(
                            onAddManually: _navigateToAddManually);
                      }

                      final heroBook = state.books.first;
                      final otherBooks = state.books.skip(1).toList();

                      return ListView(
                        padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 100), // Spacing for fab
                        children: [
                          // Hero Card
                          if (state.books.isNotEmpty) ...[
                            _buildHeroCard(heroBook),
                            const SizedBox(height: 16),
                          ],

                          // List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: otherBooks.length,
                            separatorBuilder: (c, i) => const Divider(
                                height: 1,
                                color: Colors.grey), // Light grey divider
                            itemBuilder: (context, index) {
                              final book = otherBooks[index];
                              return _buildListItem(book);
                            },
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),

          // 4. Footer Button (Floating at bottom)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _navigateToAddManually,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.primaryBlue), // Blue border
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline,
                        color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      "لم تجد كتابك؟ أضفه يدوياً",
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BookEntity book) {
    return GestureDetector(
      onTap: () => _showAddSheet(book),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // RTL
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "أفضل تطابق",
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 18, // Large
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authors.isNotEmpty ? book.authors.first : "Unknown",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Metadata
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "التاريخ", // Placeholder category
                          style: GoogleFonts.tajawal(
                              fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        const Text("•", style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 4),
                        Text(
                          "${book.rating ?? 4.9}",
                          style: GoogleFonts.tajawal(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Cover Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(24)),
              child: Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ), // Rounded all corners for image
                  image: DecorationImage(
                    image: NetworkImage(book.imageUrl ?? ''),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                  color: Colors.grey[200],
                ),
                child: book.imageUrl == null
                    ? const Icon(Icons.book, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BookEntity book) {
    return InkWell(
      onTap: () => _showAddSheet(book),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            // Chevron Left (indicator) - Visually Left
            const Icon(Icons.chevron_left, color: Colors.grey),
            const Spacer(),
            // Text Center (Right aligned logically in RTL context)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    book.title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authors.isNotEmpty ? book.authors.first : "Unknown",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Image Right
            Container(
              width: 50,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: NetworkImage(book.imageUrl ?? ''),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
              child: book.imageUrl == null
                  ? const Icon(Icons.book, color: Colors.grey, size: 20)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
