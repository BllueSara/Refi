import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_strings.dart';
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
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                              const Center(
                            child: Icon(
                              Icons.book,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.book, size: 48, color: Colors.grey),
                        ),
                ),
                // Finished Badge - Only show in "All" view when progress is 100%
                if (activeTab == AppStrings.tabAll &&
                    book.progressPercentage >= 100)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withOpacity(0.85), // Frosted Green Glass
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "تم الانتهاء",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
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
          const SizedBox(height: 12),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              //fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.authors.isNotEmpty ? book.authors.first : 'Unknown Author',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              //fontFamily: 'Tajawal',
              fontSize: 12,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 8),
          // Progress Bar
          if (book.status == BookStatus.reading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: book.progress,
                backgroundColor: AppColors.inputBorder,
                color: AppColors.primaryBlue,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${book.progressPercentage}%",
              style: const TextStyle(
                //fontFamily: 'Tajawal',
                fontSize: 10,
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
