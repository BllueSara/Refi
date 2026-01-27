import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight; // For "#Tag" if needed

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ), // Replaced withOpacity for compatibility if needed
            blurRadius: 16.r(context),
            offset: Offset(0, 4.h(context)),
          ),
        ],
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue, // #1E3A8A
            size: 28.sp(context),
          ),
          SizedBox(height: 12.h(context)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp(context),
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp(context),
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}
