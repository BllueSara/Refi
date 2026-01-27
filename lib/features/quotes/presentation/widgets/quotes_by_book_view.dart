import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/quote_entity.dart';
import '../pages/book_quotes_details_page.dart';

class QuotesByBookView extends StatelessWidget {
  final List<QuoteEntity> quotes;

  const QuotesByBookView({super.key, required this.quotes});

  @override
  Widget build(BuildContext context) {
    // Group quotes by bookId
    final Map<String, List<QuoteEntity>> quotesByBook = {};

    for (var quote in quotes) {
      // Use 'unknown' if bookId or bookTitle is null, or handle as "Miscellaneous"
      // Requirement: "only display books that have at least one saved quote"
      final key = quote.bookId ?? 'unknown';
      if (!quotesByBook.containsKey(key)) {
        quotesByBook[key] = [];
      }
      quotesByBook[key]!.add(quote);
    }

    // Filter out unknown if desired, or keep them.
    // Requirement says "Display these books", implies actual books.
    // If we have quotes without books (manual entry?), we might want to show them too.
    // implementing a "Miscellaneous" book for those without IDs.

    final bookKeys = quotesByBook.keys.toList();

    if (bookKeys.isEmpty) {
      // Should be handled by parent empty state, but just in case
      return const SizedBox.shrink();
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // Book cover ratio
        crossAxisSpacing: 16.w(context),
        mainAxisSpacing: 16.h(context),
      ),
      itemCount: bookKeys.length,
      itemBuilder: (context, index) {
        final bookId = bookKeys[index];
        final bookQuotes = quotesByBook[bookId]!;
        final firstQuote = bookQuotes.first;
        final bookTitle = firstQuote.bookTitle ?? 'بدون عنوان';
        final quoteCount = bookQuotes.length;

        final bookCoverUrl = firstQuote.bookCoverUrl;

        // Gradient Placeholder (Refi Blue Mesh)
        // Ideally use a reusable gradient constant, but defining here for now
        final gradientPlaceholder = const LinearGradient(
          colors: [
            Color(0xFFE0F2FE), // Light Blue
            Color(0xFFF0F9FF), // Lighter
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookQuotesDetailsPage(
                  bookId: bookId,
                  bookTitle: bookTitle,
                  bookCoverUrl: bookCoverUrl,
                  quotes: bookQuotes,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10.r(context),
                  offset: Offset(0, 4.h(context)),
                ),
              ],
              border: Border.all(color: AppColors.inputBorder),
            ),
            padding: EdgeInsets.all(12.w(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Expanded(
                  child: Hero(
                    tag: 'cover_$bookId',
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient:
                            bookCoverUrl == null ? gradientPlaceholder : null,
                        color: bookCoverUrl == null
                            ? null
                            : Colors.grey[200], // Fallback while loading
                        borderRadius: BorderRadius.circular(12.r(context)),
                        image: bookCoverUrl != null
                            ? DecorationImage(
                                image: NetworkImage(bookCoverUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: bookCoverUrl == null
                          ? Center(
                              child: Icon(
                                Icons.book_outlined,
                                size: 40.sp(context),
                                color: AppColors.primaryBlue.withOpacity(0.5),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 12.h(context)),

                // Book Title
                Text(
                  bookTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    //fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp(context),
                    height: 1.3,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 8.h(context)),

                // Badge
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w(context), vertical: 4.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r(context)),
                  ),
                  child: Text(
                    '$quoteCount اقتباسات',
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      fontSize: 11.sp(context),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
