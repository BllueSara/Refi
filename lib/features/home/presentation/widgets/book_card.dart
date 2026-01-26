import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/scale_button.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/home_entity.dart';

class BookCard extends StatelessWidget {
  final HomeBook book;
  final VoidCallback? onTap;

  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        width: 280.w(context), // Fixed width for horizontal list items
        margin: EdgeInsets.only(
          left: 16.w(context),
        ), // RTL: left means next item margin
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r(context)),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            // Book Cover Placeholder
            Container(
              width: 60.w(context),
              height: 90.h(context),
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(12.r(context)),
                gradient: LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: (book.coverUrl.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r(context)),
                      child: Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.book, color: Colors.grey, size: 24.sp(context)),
                          );
                        },
                      ),
                    )
                  : Center(child: Icon(Icons.book, color: Colors.grey, size: 24.sp(context))),
            ),
            SizedBox(width: 16.w(context)),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp(context),
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      fontSize: 14.sp(context),
                      color: AppColors.textSub,
                    ),
                  ),
                  SizedBox(height: 12.h(context)),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r(context)),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      backgroundColor: AppColors.inputBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                      minHeight: 6.h(context),
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    "%${(book.progress * 100).toInt()}",
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      fontSize: 12.sp(context),
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
