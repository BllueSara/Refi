import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/book_entity.dart';

class BookStatusSelector extends StatelessWidget {
  final BookStatus currentStatus;
  final Function(BookStatus) onStatusChanged;

  const BookStatusSelector({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statusChip(context, BookStatus.wishlist),
        SizedBox(width: 8.w(context)),
        _statusChip(context, BookStatus.reading),
        SizedBox(width: 8.w(context)),
        _statusChip(context, BookStatus.completed),
      ],
    );
  }

  Widget _statusChip(BuildContext context, BookStatus status) {
    final isSelected = status == currentStatus;
    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.inputBorder.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.r(context)),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSub,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14.sp(context),
            //fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }
}
