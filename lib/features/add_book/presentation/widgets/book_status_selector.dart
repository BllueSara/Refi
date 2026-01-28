import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../library/domain/entities/book_entity.dart';

class BookStatusSelector extends StatelessWidget {
  final BookStatus selectedStatus;
  final Function(BookStatus) onStatusChanged;

  const BookStatusSelector({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Order: Wishlist -> Reading -> Finished
    final list = [
      BookStatus.wishlist,
      BookStatus.reading,
      BookStatus.completed,
    ];

    final statusIcons = {
      BookStatus.wishlist: Icons.bookmark_border_rounded,
      BookStatus.reading: Icons.menu_book_rounded,
      BookStatus.completed: Icons.check_circle_outline_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bookmark_rounded,
              size: 18.sp(context),
              color: AppColors.primaryBlue,
            ),
            SizedBox(width: 8.w(context)),
            Text(
              AppStrings.readingStatusLabel,
              style: GoogleFonts.tajawal(
                fontSize: 14.sp(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h(context)),
        Container(
          padding: EdgeInsets.all(6.w(context)),
          decoration: BoxDecoration(
            color: AppColors.inputBorder.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20.r(context)),
            border: Border.all(
              color: AppColors.inputBorder.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: list.map((s) {
              final sel = selectedStatus == s;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onStatusChanged(s);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(vertical: 14.h(context)),
                    decoration: BoxDecoration(
                      gradient: sel ? AppColors.refiMeshGradient : null,
                      color: sel ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r(context)),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.3),
                                blurRadius: 8.r(context),
                                offset: Offset(0, 4.h(context)),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcons[s],
                          size: 16.sp(context),
                          color: sel ? AppColors.white : AppColors.textSub,
                        ),
                        SizedBox(width: 6.w(context)),
                        Text(
                          s.label,
                          style: GoogleFonts.tajawal(
                            fontSize: 12.sp(context),
                            fontWeight: FontWeight.bold,
                            color: sel ? AppColors.white : AppColors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
