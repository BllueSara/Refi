import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'package:lottie/lottie.dart';

class SearchStartWidget extends StatelessWidget {
  const SearchStartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/images/search imm.json',
              width: 280.w(context),
              height: 280.h(context),
            ),
            SizedBox(height: 8.h(context)),
            Text(
              AppStrings.searchStartTitle,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp(context),
                color: AppColors.textMain,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h(context)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w(context)),
              child: Text(
                AppStrings.searchStartBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 15.sp(context),
                  color: AppColors.textSub,
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: 100.h(context)), // Spacer for floating button
          ],
        ),
      ),
    );
  }
}

class SearchEmptyWidget extends StatelessWidget {
  final VoidCallback onAddManually;

  const SearchEmptyWidget({super.key, required this.onAddManually});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Illustration Container
            Container(
              width: 140.w(context),
              height: 140.h(context),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(32.r(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20.r(context),
                    offset: Offset(0, 10.h(context)),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 64.sp(context),
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
            SizedBox(height: 32.h(context)),
            Text(
              "عذراً.. لم نجد ما تبحث عنه",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp(context),
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 12.h(context)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w(context)),
              child: Text(
                "تأكد من كتابة الاسم بشكل صحيح أو جرب كلمات أخرى، أو قم بإضافته يدوياً",
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 15.sp(context),
                  color: AppColors.textSub,
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: 40.h(context)),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(24.r(context)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    blurRadius: 15.r(context),
                    offset: Offset(0, 8.h(context)),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onAddManually,
                icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 20.sp(context)),
                label: Text(
                  AppStrings.addBookManually,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp(context),
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w(context),
                    vertical: 16.h(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r(context)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100.h(context)), // Spacer
          ],
        ),
      ),
    );
  }
}
