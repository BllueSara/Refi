import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../domain/entities/library_entity.dart'; // Add this import

class LibraryBookCard extends StatelessWidget {
  final LibraryBookEntity book;
  final VoidCallback onTap;

  const LibraryBookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey[200], // Placeholder
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                // Add Image logic here later
              ),
              child: const Center(
                child: Icon(Icons.book, size: 48, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 8),
          // Progress Bar
          if (book.status == ReadingStatus.reading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: book.progress, // e.g. 0.6
                backgroundColor: AppColors.inputBorder,
                color: AppColors.primaryBlue,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${book.progressPercentage}%",
              style: const TextStyle(
                fontFamily: 'Tajawal',
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
