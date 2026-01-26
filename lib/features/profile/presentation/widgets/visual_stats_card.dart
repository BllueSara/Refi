import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class VisualStatsCard extends StatelessWidget {
  final int bookCount;
  final int annualGoal;

  const VisualStatsCard({
    super.key,
    required this.bookCount,
    required this.annualGoal,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        annualGoal > 0 ? (bookCount / annualGoal).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        gradient: AppColors.refiMeshGradient,
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 20.r(context),
            offset: Offset(0, 10.h(context)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الهدف السنوي',
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp(context),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),

          // Progress Bar
          Stack(
            children: [
              Container(
                height: 8.h(context),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r(context)),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 8.h(context),
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r(context)),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16.h(context)),
          Row(
            children: [
              Icon(Icons.menu_book, color: Colors.white, size: 20.sp(context)),
              SizedBox(width: 8.w(context)),
              Text(
                '$bookCount كتب منجزة',
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
