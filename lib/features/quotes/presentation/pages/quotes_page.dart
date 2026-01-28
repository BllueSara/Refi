import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/quote_cubit.dart';
import '../../domain/entities/quote_entity.dart';
import '../widgets/quote_card.dart';
import '../widgets/quotes_empty_view.dart';
import '../widgets/quotes_by_book_view.dart';
import '../widgets/quotes_skeleton.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage>
    with SingleTickerProviderStateMixin {
  String _activeTab = AppStrings.tabAll;
  late AnimationController _tabAnimationController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = [
    AppStrings.tabAll,
    AppStrings.filterByBook,
    AppStrings.filterFavorites,
  ];

  @override
  void initState() {
    super.initState();
    _tabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Load quotes when page opens
    context.read<QuoteCubit>().loadUserQuotes();
  }

  @override
  void dispose() {
    _tabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
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
        title: BlocBuilder<QuoteCubit, QuoteState>(
          builder: (context, state) {
            int quoteCount = 0;
            if (state is QuotesLoaded) {
              quoteCount = state.quotes.length;
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.quotesVaultTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp(context),
                    color: AppColors.textMain,
                  ),
                ),
                if (quoteCount > 0) ...[
                  SizedBox(width: 8.w(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w(context),
                      vertical: 4.h(context),
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.refiMeshGradient,
                      borderRadius: BorderRadius.circular(12.r(context)),
                    ),
                    child: Text(
                      '$quoteCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w(context),
              vertical: 12.h(context),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 16.sp(context),
              ),
              decoration: InputDecoration(
                hintText: "ابحث في الاقتباسات...",
                hintStyle: TextStyle(
                  color: AppColors.textSub.withOpacity(0.6),
                  fontSize: 14.sp(context),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSub,
                  size: 20.sp(context),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.textSub,
                          size: 20.sp(context),
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
                  borderRadius: BorderRadius.circular(12.r(context)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w(context),
                  vertical: 12.h(context),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
          // Filter Tabs
          BlocBuilder<QuoteCubit, QuoteState>(
            builder: (context, state) {
              int allCount = 0;
              int favoritesCount = 0;
              int booksCount = 0;

              if (state is QuotesLoaded) {
                allCount = state.quotes.length;
                favoritesCount = state.quotes.where((q) => q.isFavorite).length;
                booksCount = state.quotes
                    .where((q) => q.bookId != null || q.bookTitle != null)
                    .length;
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    vertical: 16.h(context), horizontal: 16.w(context)),
                child: Row(
                  children: _tabs.map((tab) {
                    final isActive = _activeTab == tab;

                    int count = 0;
                    if (tab == AppStrings.tabAll) {
                      count = allCount;
                    } else if (tab == AppStrings.filterFavorites) {
                      count = favoritesCount;
                    } else if (tab == AppStrings.filterByBook) {
                      count = booksCount;
                    }

                    return Padding(
                      padding: EdgeInsets.only(left: 12.0.w(context)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w(context),
                          vertical: 10.h(context),
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isActive ? AppColors.refiMeshGradient : null,
                          color: isActive ? null : AppColors.inputBorder,
                          borderRadius: BorderRadius.circular(24.r(context)),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryBlue.withOpacity(0.3),
                                    blurRadius: 8.r(context),
                                    offset: Offset(0, 4.h(context)),
                                  ),
                                ]
                              : null,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeTab = tab;
                            });
                            _tabAnimationController.forward(from: 0.0);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tab,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textSub,
                                  fontSize: 14.sp(context),
                                ),
                              ),
                              if (count > 0) ...[
                                SizedBox(width: 6.w(context)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w(context),
                                    vertical: 2.h(context),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white.withOpacity(0.3)
                                        : AppColors.textSub.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(10.r(context)),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.textSub,
                                      fontSize: 11.sp(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // Quote List
          Expanded(
            child: BlocBuilder<QuoteCubit, QuoteState>(
              builder: (context, state) {
                if (state is QuoteLoading) {
                  return const QuotesSkeleton();
                }

                if (state is QuoteError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0.w(context)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp(context),
                            color: AppColors.textPlaceholder,
                          ),
                          SizedBox(height: 16.h(context)),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              //fontFamily: 'Tajawal',
                              color: AppColors.textSub,
                              fontSize: 14.sp(context),
                            ),
                          ),
                          SizedBox(height: 16.h(context)),
                          ElevatedButton(
                            onPressed: () {
                              context.read<QuoteCubit>().loadUserQuotes();
                            },
                            child: Text('إعادة المحاولة',
                                style: TextStyle(fontSize: 14.sp(context))),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is QuotesLoaded) {
                  final quotes = state.quotes;

                  if (quotes.isEmpty) {
                    return QuotesEmptyView(activeTab: _activeTab);
                  }

                  // Filter logic based on tab
                  List<QuoteEntity> displayedQuotes = quotes;

                  // Filter by tab first
                  if (_activeTab == AppStrings.filterByBook) {
                    displayedQuotes = quotes
                        .where((q) => q.bookId != null || q.bookTitle != null)
                        .toList();
                  } else if (_activeTab == AppStrings.filterFavorites) {
                    displayedQuotes =
                        quotes.where((q) => q.isFavorite).toList();
                  }

                  // Apply search filter
                  if (_searchController.text.isNotEmpty) {
                    final query = _searchController.text.toLowerCase();
                    displayedQuotes = displayedQuotes.where((quote) {
                      final textMatch =
                          quote.text.toLowerCase().contains(query);
                      final bookTitleMatch =
                          quote.bookTitle?.toLowerCase().contains(query) ??
                              false;
                      final bookAuthorMatch =
                          quote.bookAuthor?.toLowerCase().contains(query) ??
                              false;
                      final notesMatch =
                          quote.notes?.toLowerCase().contains(query) ?? false;
                      return textMatch ||
                          bookTitleMatch ||
                          bookAuthorMatch ||
                          notesMatch;
                    }).toList();
                  }

                  // Check if filtered quotes are empty
                  if (displayedQuotes.isEmpty) {
                    return QuotesEmptyView(activeTab: _activeTab);
                  }

                  // Handle "By Book" view separately
                  if (_activeTab == AppStrings.filterByBook) {
                    return QuotesByBookView(quotes: displayedQuotes);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<QuoteCubit>().loadUserQuotes();
                    },
                    color: AppColors.primaryBlue,
                    child: ListView.separated(
                      padding: EdgeInsets.all(16.w(context)),
                      addAutomaticKeepAlives: true,
                      itemCount: displayedQuotes.length,
                      separatorBuilder: (c, i) =>
                          SizedBox(height: 16.h(context)),
                      itemBuilder: (context, index) {
                        final quote = displayedQuotes[index];
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          child: QuoteCard(quote: quote),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      // Removed FloatingActionButton as requested
    );
  }
}
