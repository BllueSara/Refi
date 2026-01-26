import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/book_entity.dart';

class LibraryBookCard extends StatelessWidget {
  final BookEntity book;
  final VoidCallback onTap;
  final String? activeTab;

  const LibraryBookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r(context)),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10.r(context),
                        offset: Offset(0, 4.h(context)),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: book.imageUrl != null
                      ? Image.network(
                          book.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(
                            child: Icon(
                              Icons.book,
                              size: 48.sp(context),
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.book, size: 48.sp(context), color: Colors.grey),
                        ),
                ),
                // Finished Badge - Only show in "All" view when progress is 100%
                if (activeTab == AppStrings.tabAll &&
                    book.progressPercentage >= 100)
                  Positioned(
                    top: 12.h(context),
                    left: 12.w(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r(context)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w(context),
                            vertical: 6.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withOpacity(0.85), // Frosted Green Glass
                            borderRadius: BorderRadius.circular(12.r(context)),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 14.sp(context),
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w(context)),
                              Text(
                                "تم الانتهاء",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp(context),
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(0, 1.h(context)),
                                      blurRadius: 2.r(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.h(context)),
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
            book.authors.isNotEmpty ? book.authors.first : 'Unknown Author',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              //fontFamily: 'Tajawal',
              fontSize: 12.sp(context),
              color: AppColors.textSub,
            ),
          ),
          SizedBox(height: 8.h(context)),
          // Progress Bar
          if (book.status == BookStatus.reading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r(context)),
              child: LinearProgressIndicator(
                value: book.progress,
                backgroundColor: AppColors.inputBorder,
                color: AppColors.primaryBlue,
                minHeight: 6.h(context),
              ),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              "${book.progressPercentage}%",
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontSize: 10.sp(context),
                color: AppColors.secondaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
