import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/quote_entity.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bookCoverUrl != null)
              Hero(
                tag: 'cover_$bookId',
                child: Container(
                  width: 30.w(context),
                  height: 45.h(context),
                  margin: EdgeInsets.only(left: 8.w(context)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r(context)),
                    image: DecorationImage(
                      image: NetworkImage(bookCoverUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            Flexible(
              child: Text(
                bookTitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp(context),
                  color: AppColors.textMain,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w(context)),
        itemCount: quotes.length,
        separatorBuilder: (c, i) => SizedBox(height: 16.h(context)),
        itemBuilder: (context, index) {
          final quote = quotes[index];
          return QuoteCard(quote: quote);
        },
      ),
    );
  }
}
