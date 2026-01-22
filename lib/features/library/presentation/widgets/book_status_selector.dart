import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
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
        _statusChip(context, BookStatus.reading, AppStrings.statusReading),
        const SizedBox(width: 8),
        _statusChip(context, BookStatus.wishlist, AppStrings.statusWantToRead),
        const SizedBox(width: 8),
        _statusChip(context, BookStatus.completed, AppStrings.statusFinished),
      ],
    );
  }

  Widget _statusChip(BuildContext context, BookStatus status, String label) {
    final isSelected = status == currentStatus;
    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.inputBorder.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSub,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }
}
