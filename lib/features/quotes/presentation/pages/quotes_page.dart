import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/quote_cubit.dart';
import '../../domain/entities/quote_entity.dart';
import '../widgets/quote_card.dart';
import '../widgets/quotes_empty_view.dart';
import '../widgets/quotes_by_book_view.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String _activeTab = AppStrings.tabAll;

  final List<String> _tabs = [
    AppStrings.tabAll,
    AppStrings.filterByBook,
    AppStrings.filterFavorites,
  ];

  @override
  void initState() {
    super.initState();
    // Load quotes when page opens
    context.read<QuoteCubit>().loadUserQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.search,
              color: AppColors.textMain, size: 28.sp(context)),
          onPressed: () {},
        ),
        title: Text(
          AppStrings.quotesVaultTitle,
          style: TextStyle(
            //fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 20.sp(context),
            color: AppColors.textMain,
          ),
        ),
        actions: [SizedBox(width: 48.w(context))],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                vertical: 16.h(context), horizontal: 16.w(context)),
            child: Row(
              children: _tabs.map((tab) {
                final isActive = _activeTab == tab;
                return Padding(
                  padding: EdgeInsets.only(left: 12.0.w(context)),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = tab),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w(context),
                        vertical: 10.h(context),
                      ),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.refiMeshGradient : null,
                        color: isActive ? null : AppColors.inputBorder,
                        borderRadius: BorderRadius.circular(24.r(context)),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          //fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : AppColors.textSub,
                          fontSize: 14.sp(context),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Quote List
          Expanded(
            child: BlocBuilder<QuoteCubit, QuoteState>(
              builder: (context, state) {
                if (state is QuoteLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                    return const QuotesEmptyView();
                  }

                  // Filter logic based on tab
                  List<QuoteEntity> displayedQuotes = quotes;

                  if (_activeTab == AppStrings.filterByBook) {
                    // Check if valid books exist, otherwise show specific empty state
                    if (quotes
                        .any((q) => q.bookId != null || q.bookTitle != null)) {
                      return QuotesByBookView(quotes: quotes);
                    } else {
                      // Empty state for "By Book" if no books found
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: 80.sp(context),
                              color: AppColors.textPlaceholder.withOpacity(0.3),
                            ),
                            SizedBox(height: 16.h(context)),
                            Text(
                              'لم تضف أي اقتباسات لهذا الكتاب بعد..\nابدأ بالمسح الآن!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                //fontFamily: 'Tajawal',
                                fontSize: 16.sp(context),
                                color: AppColors.textMain,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else if (_activeTab == AppStrings.filterFavorites) {
                    displayedQuotes =
                        quotes.where((q) => q.isFavorite).toList();
                    if (displayedQuotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 80.sp(context),
                              color: AppColors.textPlaceholder.withOpacity(0.3),
                            ),
                            SizedBox(height: 16.h(context)),
                            Text(
                              'لم تقم بإضافة أي اقتباسات للمفضلة بعد',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                //fontFamily: 'Tajawal',
                                fontSize: 16.sp(context),
                                color: AppColors.textMain,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<QuoteCubit>().loadUserQuotes();
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.all(16.w(context)),
                      // Optimization: set itemExtent if height is fixed, prevents layout jumps.
                      // However cards have variable height due to content, so we cannot use itemExtent.
                      // We rely on standard ListView builder optimization.
                      addAutomaticKeepAlives: true,
                      itemCount: displayedQuotes.length,
                      separatorBuilder: (c, i) =>
                          SizedBox(height: 16.h(context)),
                      itemBuilder: (context, index) {
                        final quote = displayedQuotes[index];
                        return QuoteCard(quote: quote);
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
