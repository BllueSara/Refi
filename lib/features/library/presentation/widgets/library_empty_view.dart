import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../add_book/presentation/screens/search_screen.dart';

class LibraryEmptyView extends StatelessWidget {
  final String? activeTab;

  const LibraryEmptyView({super.key, this.activeTab});

  String get _title {
    switch (activeTab) {
      case AppStrings.tabReading:
        return "رفوفك الحالية فارغة.. ما هو رفيقك القادم؟";
      case AppStrings.tabCompleted:
        return "مكتبة الإنجازات تنتظر بطلها الأول!";
      case AppStrings.tabWishlist:
        return "قائمة الأمنيات فارغة، استكشف كتباً تثير فضولك.";
      default:
        return "مكتبتك بانتظار كتابك الأول..";
    }
  }

  String get _subtitle {
    switch (activeTab) {
      case AppStrings.tabReading:
        return "ابدأ رحلتك المعرفية الآن وأضف الكتب التي تود قراءتها حالياً";
      case AppStrings.tabCompleted:
        return "احتفل بإنجازاتك القرائية وأضف الكتب التي أنهيت قراءتها";
      case AppStrings.tabWishlist:
        return "استكشف آلاف الكتب المتاحة وأضف ما يثير فضولك إلى قائمة أمنياتك";
      default:
        return "ابدأ رحلتك المعرفية الآن وأضف الكتب التي تود قراءتها أو قرأتها مسبقاً";
    }
  }

  String get _lottieAsset {
    switch (activeTab) {
      case AppStrings.tabReading:
        return 'assets/lottie/Student.json';
      case AppStrings.tabCompleted:
        return 'assets/lottie/completed-book.json';
      case AppStrings.tabWishlist:
        return 'assets/lottie/Books stack.json';
      default:
        return 'assets/images/books.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 24.w(context), vertical: 16.h(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium Lottie Animation - Reduced size to fit screen
            SizedBox(
              width: 220.w(context),
              height: 220.h(context),
              child: Lottie.asset(
                _lottieAsset,
                fit: BoxFit.contain,
                // Completely transparent - blends with theme background
                // No container, no gray backgrounds
              ),
            ),
            SizedBox(height: 24.h(context)),
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
              child: Text(
                _title,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp(context),
                  color: AppColors.textMain,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 8.h(context)),
            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 14.sp(context),
                  color: AppColors.textSub,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 32.h(context)),

            // Premium Button
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(24.r(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 20.r(context),
                    offset: Offset(0, 8.h(context)),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()),
                  );
                },
                icon: Icon(Icons.search,
                    color: Colors.white, size: 20.sp(context)),
                label: Text(
                  "ابدأ بالبحث عن كتاب",
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
                    vertical: 14.h(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r(context)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
