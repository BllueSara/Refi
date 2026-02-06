import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class PurchaseProcessingSheet extends StatelessWidget {
  final String title;
  final String subtitle;

  const PurchaseProcessingSheet({
    super.key,
    this.title = 'جاري تأكيد اشتراكك..',
    this.subtitle = 'لحظات لتشرع أبواب المعرفة',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: 24.w(context), vertical: 32.h(context)),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Creamy background standard in Refi
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r(context)),
          topRight: Radius.circular(24.r(context)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h(context)),
          // Book Animation
          SizedBox(
            width: 150.w(context),
            height: 150.h(context),
            child: Lottie.asset(
              'assets/lottie/Book.json', // Using the existing book animation
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 24.h(context)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18.sp(context),
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14.sp(context),
              color: AppColors.textSub,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h(context)),
        ],
      ),
    );
  }
}
