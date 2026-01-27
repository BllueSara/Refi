import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../utils/responsive_utils.dart';

class RefiBookCard extends StatelessWidget {
  final String title;
  final String author;
  final double progress; // 0.0 to 1.0
  final String? coverUrl;
  final VoidCallback? onTap;
  final String? heroTag;

  const RefiBookCard({
    super.key,
    required this.title,
    required this.author,
    required this.progress,
    this.coverUrl,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 24.r(context),
            offset: Offset(0, 12.h(context)),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6.r(context),
            offset: Offset(0, 2.h(context)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius.r(context)),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p12.w(context)),
            child: Row(
              children: [
                // Book Cover
                Hero(
                  tag: heroTag ?? title,
                  child: Container(
                    width: 80.w(context),
                    height: 120.h(context),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(AppSizes.p12.r(context)),
                      image: coverUrl != null
                          ? DecorationImage(
                              image: NetworkImage(coverUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8.r(context),
                          offset: Offset(0, 4.h(context)),
                        ),
                      ],
                    ),
                    child: coverUrl == null
                        ? Icon(Icons.book,
                            color: Colors.grey[400], size: 40.sp(context))
                        : null,
                  ),
                ),
                SizedBox(width: AppSizes.p16.w(context)),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp(context),
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.p4.h(context)),
                      Text(
                        author,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSub,
                              fontSize: 14.sp(context),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.p16.h(context)),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r(context)),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.inputBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue,
                          ),
                          minHeight: 6.h(context),
                        ),
                      ),
                      SizedBox(height: AppSizes.p4.h(context)),
                      Text(
                        '${(progress * 100).toInt()}% مكتمل',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.secondaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
