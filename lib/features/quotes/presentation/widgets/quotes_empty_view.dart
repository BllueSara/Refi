import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class QuotesEmptyView extends StatefulWidget {
  const QuotesEmptyView({super.key});

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
                  'assets/images/books.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              SizedBox(height: 32.h(context)),

              // Contextual Copy
              Text(
                'كلماتك المفضلة تنتظر أن تُحفظ هنا..\nابدأ بمسح أول اقتباس.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp(context),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMain,
                ),
              ),
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
