import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class FeelingChip extends StatelessWidget {
  final String feeling;
  final bool isSelected;
  final VoidCallback onTap;

  const FeelingChip({
    super.key,
    required this.feeling,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w(context),
          vertical: 12.h(context),
        ),
        margin: EdgeInsets.only(left: 8.w(context)),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.refiMeshGradient : null,
          color: isSelected ? null : AppColors.inputBorder,
          borderRadius: BorderRadius.circular(24.r(context)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8.r(context),
                    offset: Offset(0, 4.h(context)),
                  ),
                ]
              : null,
        ),
        child: Text(
          feeling,
          style: TextStyle(
            fontSize: 14.sp(context),
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSub,
          ),
        ),
      ),
    );
  }
}
