import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';

class QuotesEmptyView extends StatefulWidget {
  final String? activeTab;

  const QuotesEmptyView({super.key, this.activeTab});

  @override
  State<QuotesEmptyView> createState() => _QuotesEmptyViewState();
}

class _QuotesEmptyViewState extends State<QuotesEmptyView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _lottieAsset {
    switch (widget.activeTab) {
      case AppStrings.filterByBook:
        return 'assets/lottie/Book.json';
      case AppStrings.filterFavorites:
        return 'assets/lottie/Testimonials Icon.json';
      case AppStrings.tabAll:
      default:
        return 'assets/images/books.json';
    }
  }

  String get _title {
    switch (widget.activeTab) {
      case AppStrings.filterByBook:
        return 'لم تضف أي اقتباسات لهذا الكتاب بعد..\nابدأ بالمسح الآن!';
      case AppStrings.filterFavorites:
        return 'لم تقم بإضافة أي اقتباسات للمفضلة بعد';
      case AppStrings.tabAll:
      default:
        return 'كلماتك المفضلة تنتظر أن تُحفظ هنا..\nابدأ بمسح أول اقتباس.';
    }
  }

  String? get _subtitle {
    switch (widget.activeTab) {
      case AppStrings.filterFavorites:
        return 'اضغط على أيقونة القلب لحفظ اقتباساتك المفضلة';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              SizedBox(
                height: 250.h(context),
                width: 250.w(context),
                child: Lottie.asset(
                  _lottieAsset,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              SizedBox(height: 32.h(context)),

              // Contextual Copy
              Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp(context),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMain,
                ),
              ),
              if (_subtitle != null) ...[
                SizedBox(height: 8.h(context)),
                Text(
                  _subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp(context),
                    height: 1.4,
                    color: AppColors.textSub,
                  ),
                ),
              ],
              SizedBox(height: 16.h(context)),
              // Decorative dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w(context)),
                    width: 8.w(context),
                    height: 8.h(context),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
