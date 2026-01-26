import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class QuotesEmptyView extends StatelessWidget {
  const QuotesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F9FF), // Very light blue/white
            Colors.white,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation
          SizedBox(
            height: 250.h(context),
            width: 250.w(context),
            child: Lottie.asset(
              'assets/images/books.json', // Using existing book animation as placeholder
              fit: BoxFit.contain,
              // Zero gray background guaranteed by parent container
            ),
          ),
          SizedBox(height: 32.h(context)),

          // Contextual Copy
          Text(
            'كلماتك المفضلة تنتظر أن تُحفظ هنا..\nابدأ بمسح أول اقتباس.',
            textAlign: TextAlign.center,
            style: TextStyle(
              //fontFamily: 'Tajawal',
              fontSize: 18.sp(context),
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
