import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class RefiBookCard extends StatelessWidget {
  final String title;
  final String author;
  final double progress; // 0.0 to 1.0
  final String? coverUrl;
  final VoidCallback? onTap;

  const RefiBookCard({
    super.key,
    required this.title,
    required this.author,
    required this.progress,
    this.coverUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: Row(
            children: [
              // Book Cover Placeholder or Image
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppSizes.p12),
                  image: coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: coverUrl == null
                    ? Icon(Icons.book, color: Colors.grey[400], size: 40)
                    : null,
              ),
              const SizedBox(width: AppSizes.p16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.p4),
                    Text(
                      author,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.inputBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p4),
                    Text(
                      '${(progress * 100).toInt()}% مكتمل',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
