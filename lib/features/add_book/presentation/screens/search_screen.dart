import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/refi_success_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../library/presentation/cubit/search_cubit.dart';
import '../widgets/search_states_widgets.dart';
import 'manual_entry_screen.dart';

import '../../../../core/widgets/glassmorphic_notification_modal.dart';
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
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        return;
      }
      context.read<SearchCubit>().search(query.trim());
    });
  }

  void _navigateToAddManually() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
    );
  }

  /// Step 2: The Success Screen
  void _showSuccessScreen(BuildContext context, BookEntity book) {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => RefiSuccessWidget(
          title: "تمت إضافة الكتاب بنجاح!",
          subtitle: "أصبح الكتاب الآن جزءاً من رحلتك المعرفية المثرية",
          primaryButtonLabel: "العودة للبحث",
          onPrimaryAction: () {
            Navigator.pop(ctx);
          },
          secondaryButtonLabel: "العودة للمكتبة",
          onSecondaryAction: () {
            Navigator.pop(ctx);
            Navigator.pop(context);
          },
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r(context)),
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
                padding: EdgeInsets.symmetric(
                    horizontal: 24.w(context), vertical: 32.h(context)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40.w(context),
                      height: 4.h(context),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r(context)),
                      ),
                    ),
                    SizedBox(height: 24.h(context)),
                    Container(
                      width: 120.w(context),
                      height: 180.h(context),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20.r(context),
                            offset: Offset(0, 10.h(context)),
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
                          ? Icon(Icons.book,
                              size: 50.sp(context), color: Colors.grey)
                          : null,
                    ),
                    SizedBox(height: 24.h(context)),
                    Text(
                      "هذا الكتاب موجود بالفعل في مكتبتك",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 20.sp(context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 32.h(context)),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h(context),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.refiMeshGradient,
                          borderRadius: BorderRadius.circular(16.r(context)),
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
                              borderRadius:
                                  BorderRadius.circular(16.r(context)),
                            ),
                          ),
                          child: Text(
                            "انتقل إلى الكتاب في مكتبتي",
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp(context),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h(context)),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        "إغلاق",
                        style: GoogleFonts.tajawal(
                          fontSize: 16.sp(context),
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
        BookStatus selectedStatus = BookStatus.reading;

        return StatefulBuilder(
          builder: (sheetContext, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.w(context), vertical: 12.h(context)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40.w(context),
                          height: 4.h(context),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.r(context)),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h(context)),

                      // Book Cover
                      Container(
                        width: 120.w(context),
                        height: 180.h(context),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r(context)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20.r(context),
                              offset: Offset(0, 10.h(context)),
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
                            ? Icon(Icons.book,
                                size: 50.sp(context), color: Colors.grey)
                            : null,
                      ),
                      SizedBox(height: 24.h(context)),

                      // Title & Subtitle
                      Text(
                        "هل تود إضافة هذا الكتاب؟",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 20.sp(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 8.h(context)),
                      Text(
                        "سيتم حفظ الكتاب في قائمة كتبك الخاصة",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 14.sp(context),
                          color: AppColors.textSub,
                        ),
                      ),
                      SizedBox(height: 32.h(context)),

                      // Status Selector
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.w(context)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12.r(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<BookStatus>(
                            value: selectedStatus,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down_circle_outlined,
                                color: AppColors.primaryBlue,
                                size: 24.sp(context)),
                            onChanged: (BookStatus? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: BookStatus.wishlist,
                                child: Text(
                                  BookStatus.wishlist.label,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16.sp(context),
                                    color: AppColors.textMain,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BookStatus.reading,
                                child: Text(
                                  BookStatus.reading.label,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16.sp(context),
                                    color: AppColors.textMain,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              DropdownMenuItem(
                                value: BookStatus.completed,
                                child: Text(
                                  BookStatus.completed.label,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16.sp(context),
                                    color: AppColors.textMain,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h(context)),

                      // Primary Action
                      SizedBox(
                        width: double.infinity,
                        height: 56.h(context),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.refiMeshGradient,
                            borderRadius: BorderRadius.circular(16.r(context)),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // 1. Instant Feedback
                              HapticFeedback.lightImpact();
                              Navigator.pop(ctx); // Close Sheet first

                              // 2. Show Success Screen Immediately (Optimistic)
                              // Use 'context' (parent context) instead of 'sheetContext'
                              if (context.mounted) {
                                _showSuccessScreen(context, book);
                              }

                              // 3. Perform Logic in Background
                              // Fire-and-forget style to keep UI responsive
                              context
                                  .read<LibraryCubit>()
                                  .addBook(
                                      book.copyWith(status: selectedStatus))
                                  .catchError((e) {
                                // 4. Error Safety Net
                                // If it fails, we should ideally show a snackbar or revert.
                                // Since the success screen is already up, we might show a toast there.
                                debugPrint("Failed to add book: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('حدث خطأ: $e')),
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16.r(context)),
                              ),
                            ),
                            child: Text(
                              "إضافة إلى مكتبتي",
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp(context),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h(context)),

                      // Secondary Action
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          "إلغاء",
                          style: GoogleFonts.tajawal(
                            fontSize: 16.sp(context),
                            color: AppColors.textSub,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h(context)),
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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20.sp(context)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          tooltip: 'رجوع',
        ),
        leadingWidth: 56.w(context),
        title: Text(
          "بحث",
          style: GoogleFonts.tajawal(
            color: Colors.black,
            fontSize: 20.sp(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Search Field
              Padding(
                padding: EdgeInsets.all(16.0.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      textAlign: TextAlign.right,
                      onChanged: _onSearchChanged,
                      style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp(context)),
                      decoration: InputDecoration(
                        hintText: "ابن خلدون",
                        hintStyle: GoogleFonts.tajawal(
                            color: Colors.grey, fontSize: 14.sp(context)),
                        suffixIcon: Icon(Icons.search,
                            color: Colors.grey, size: 24.sp(context)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r(context)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w(context), vertical: 16.h(context)),
                      ),
                    ),
                    SizedBox(height: 16.h(context)),
                    // Sub-header
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // RTL align right
                      children: [
                        Text(
                          "نتائج البحث",
                          style: GoogleFonts.tajawal(
                            fontSize: 14.sp(context),
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
                      return Center(
                        child: Lottie.asset(
                          'assets/images/search imm.json',
                          width: 200.w(context),
                          height: 200.h(context),
                        ),
                      );
                    } else if (state is SearchError) {
                      return Center(
                          child: Text(state.message,
                              style: GoogleFonts.tajawal(
                                  fontSize: 14.sp(context))));
                    } else if (state is SearchSuccess) {
                      if (state.books.isEmpty) {
                        return SearchEmptyWidget(
                            onAddManually: _navigateToAddManually);
                      }

                      final heroBook = state.books.first;
                      final otherBooks = state.books.skip(1).toList();

                      return ListView(
                        padding: EdgeInsets.only(
                            left: 16.w(context),
                            right: 16.w(context),
                            bottom: 100.h(context)), // Spacing for fab
                        children: [
                          // Hero Card
                          if (state.books.isNotEmpty) ...[
                            _buildHeroCard(heroBook),
                            SizedBox(height: 16.h(context)),
                          ],

                          // List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: otherBooks.length,
                            separatorBuilder: (c, i) => Divider(
                                height: 1.h(context),
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
            bottom: 24.h(context),
            left: 16.w(context),
            right: 16.w(context),
            child: SizedBox(
              width: double.infinity,
              height: 56.h(context),
              child: OutlinedButton(
                onPressed: _navigateToAddManually,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.primaryBlue), // Blue border
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r(context))),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: AppColors.primaryBlue, size: 24.sp(context)),
                    SizedBox(width: 8.w(context)),
                    Text(
                      "لم تجد كتابك؟ أضفه يدوياً",
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        fontSize: 16.sp(context),
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
    final libraryState = context.read<LibraryCubit>().state;
    bool isInLibrary = false;
    if (libraryState is LibraryLoaded) {
      isInLibrary = libraryState.books.any((b) =>
          b.title.trim().toLowerCase() == book.title.trim().toLowerCase());
    }

    return GestureDetector(
      onTap: isInLibrary
          ? () {
              showGlassmorphicNotification(
                context,
                onAction: () async {
                  BookEntity? libraryBook;
                  if (libraryState is LibraryLoaded) {
                    try {
                      libraryBook = libraryState.books.firstWhere((b) =>
                          b.title.trim().toLowerCase() ==
                          book.title.trim().toLowerCase());
                    } catch (_) {}
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookDetailsPage(book: libraryBook ?? book),
                    ),
                  );
                },
              );
            }
          : () => _showAddSheet(book),
      child: Container(
        constraints: BoxConstraints(minHeight: 180.h(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10.r(context),
              offset: Offset(0, 4.h(context)),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0.w(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end, // RTL
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge
                      Builder(builder: (context) {
                        final libraryState = context.read<LibraryCubit>().state;
                        bool isInLibrary = false;
                        if (libraryState is LibraryLoaded) {
                          isInLibrary = libraryState.books.any((b) =>
                              b.title.trim().toLowerCase() ==
                              book.title.trim().toLowerCase());
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w(context), vertical: 4.h(context)),
                          decoration: BoxDecoration(
                            color: isInLibrary
                                ? Colors.green.withOpacity(0.1)
                                : AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r(context)),
                          ),
                          child: Text(
                            isInLibrary ? "موجود في مكتبتك" : "أفضل تطابق",
                            style: GoogleFonts.tajawal(
                              fontSize: 12.sp(context),
                              color: isInLibrary
                                  ? Colors.green
                                  : AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 8.h(context)),
                      Flexible(
                        child: Text(
                          book.title,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 18.sp(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text(
                        book.authors.isNotEmpty
                            ? book.authors.first
                            : "Unknown",
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 14.sp(context),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 12.h(context)),
                      // Metadata
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "التاريخ", // Placeholder category
                            style: GoogleFonts.tajawal(
                                fontSize: 12.sp(context), color: Colors.grey),
                          ),
                          SizedBox(width: 4.w(context)),
                          Text("•",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.sp(context))),
                          SizedBox(width: 4.w(context)),
                          Text(
                            "${book.rating ?? 4.9}",
                            style: GoogleFonts.tajawal(
                                fontSize: 12.sp(context),
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4.w(context)),
                          Icon(Icons.star,
                              size: 14.sp(context), color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(24.r(context))),
                child: Container(
                  width: 120.w(context),
                  // height: 180, // Removed to allow stretching via IntrinsicHeight
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24.r(context)),
                      bottomRight: Radius.circular(24.r(context)),
                      topLeft: Radius.circular(24.r(context)),
                      bottomLeft: Radius.circular(24.r(context)),
                    ), // Rounded all corners for image
                    image: DecorationImage(
                      image: NetworkImage(book.imageUrl ?? ''),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                    color: Colors.grey[200],
                  ),
                  child: book.imageUrl == null
                      ? Icon(Icons.book,
                          size: 40.sp(context), color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(width: 16.w(context)),
            ],
          ),
        ), // Close IntrinsicHeight
      ), // Close Container
    ); // Close GestureDetector
  }

  Widget _buildListItem(BookEntity book) {
    final libraryState = context.read<LibraryCubit>().state;
    bool isInLibrary = false;
    if (libraryState is LibraryLoaded) {
      isInLibrary = libraryState.books.any((b) =>
          b.title.trim().toLowerCase() == book.title.trim().toLowerCase());
    }

    return InkWell(
      onTap: isInLibrary
          ? () {
              showGlassmorphicNotification(
                context,
                onAction: () async {
                  BookEntity? libraryBook;
                  if (libraryState is LibraryLoaded) {
                    try {
                      libraryBook = libraryState.books.firstWhere((b) =>
                          b.title.trim().toLowerCase() ==
                          book.title.trim().toLowerCase());
                    } catch (_) {}
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookDetailsPage(book: libraryBook ?? book),
                    ),
                  );
                },
              );
            }
          : () => _showAddSheet(book),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0.h(context)),
        child: Row(
          children: [
            // Chevron Left (indicator) - Visually Left
            Icon(
              isInLibrary ? Icons.check_circle : Icons.chevron_left,
              color: isInLibrary ? Colors.green : Colors.grey,
              size: 24.sp(context),
            ),
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
                      fontSize: 16.sp(context),
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    book.authors.isNotEmpty ? book.authors.first : "Unknown",
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 14.sp(context),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w(context)),
            // Image Right
            Container(
              width: 50.w(context),
              height: 75.h(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r(context)),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: NetworkImage(book.imageUrl ?? ''),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
              child: book.imageUrl == null
                  ? Icon(Icons.book, color: Colors.grey, size: 20.sp(context))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
