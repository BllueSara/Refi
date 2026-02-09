import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/quote_entity.dart';
import '../cubit/quote_cubit.dart';
import '../widgets/quote_card.dart';

class BookQuotesDetailsPage extends StatelessWidget {
  final String bookId;
  final String bookTitle;
  final String? bookCoverUrl;
  final List<QuoteEntity> quotes;

  const BookQuotesDetailsPage({
    super.key,
    required this.bookId,
    required this.bookTitle,
    this.bookCoverUrl,
    required this.quotes,
  });

  @override
  Widget build(BuildContext context) {
    final bookAuthor = quotes.isNotEmpty ? quotes.first.bookAuthor : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.back,
                color: AppColors.textMain,
                size: 28.sp(context),
              ),
            ],
          ),
        ),
        title: Text(
          "اقتباسات الكتاب",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 20.sp(context)),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<QuoteCubit, QuoteState>(
        builder: (context, state) {
          List<QuoteEntity> displayQuotes = quotes;

          if (state is QuotesLoaded) {
            // Filter quotes for this book
            final bookQuotes = state.quotes.where((q) {
              final matchesId = q.bookId == bookId;
              // If bookId is null/empty on quote but titles match, fallback to title match
              if (!matchesId && bookId == 'unknown' && q.bookId == null)
                return true;
              return matchesId;
            }).toList();

            // Should we update displayQuotes?
            // The initial list might be passed from a snapshot.
            // If we have fresh data, use it.
            if (bookQuotes.isNotEmpty || state.quotes.isNotEmpty) {
              displayQuotes = bookQuotes;
            }
          }

          return CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.w(context)),
                  child: Column(
                    children: [
                      // Book Cover
                      Hero(
                        tag: 'cover_$bookId',
                        child: Container(
                          width: 140.w(context),
                          height: 210.h(context),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r(context)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20.r(context),
                                offset: Offset(0, 10.h(context)),
                              ),
                            ],
                            color: const Color(0xFFA8C6CB),
                            image: bookCoverUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(bookCoverUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: bookCoverUrl == null
                              ? Center(
                                  child: Icon(
                                    Icons.book,
                                    size: 48.sp(context),
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 24.h(context)),

                      // Book Title
                      Text(
                        bookTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 24.sp(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),

                      // Book Author
                      if (displayQuotes.isNotEmpty &&
                          displayQuotes.first.bookAuthor != null) ...[
                        SizedBox(height: 8.h(context)),
                        Text(
                          displayQuotes.first.bookAuthor!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            fontSize: 16.sp(context),
                            color: AppColors.textSub,
                          ),
                        ),
                      ],

                      SizedBox(height: 16.h(context)),

                      // Quotes Count Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w(context),
                          vertical: 10.h(context),
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.refiMeshGradient,
                          borderRadius: BorderRadius.circular(24.r(context)),
                        ),
                        child: Text(
                          '${displayQuotes.length} ${displayQuotes.length == 1 ? 'اقتباس' : 'اقتباسات'}',
                          style: GoogleFonts.tajawal(
                            fontSize: 14.sp(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quotes List
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quote = displayQuotes[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h(context)),
                        child: QuoteCard(quote: quote),
                      );
                    },
                    childCount: displayQuotes.length,
                  ),
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 24.h(context)),
              ),
            ],
          );
        },
      ),
    );
  }
}
