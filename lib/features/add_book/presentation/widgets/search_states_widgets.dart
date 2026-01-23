import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
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
              width: 280,
              height: 280,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.searchStartTitle,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textMain,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                AppStrings.searchStartBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  color: AppColors.textSub,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 100), // Spacer for floating button
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
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "عذراً.. لم نجد ما تبحث عنه",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                "تأكد من كتابة الاسم بشكل صحيح أو جرب كلمات أخرى، أو قم بإضافته يدوياً",
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  color: AppColors.textSub,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onAddManually,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: Text(
                  AppStrings.addBookManually,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100), // Spacer
          ],
        ),
      ),
    );
  }
}
