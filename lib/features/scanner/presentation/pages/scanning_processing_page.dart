import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as dart_math;
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/scanner_cubit.dart';

class ScanningProcessingPage extends StatefulWidget {
  final String imagePath;

  const ScanningProcessingPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ScanningProcessingPage> createState() => _ScanningProcessingPageState();
}

class _ScanningProcessingPageState extends State<ScanningProcessingPage> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerCubit, ScannerState>(
      listener: (context, state) {
        if (state is ScannerSuccess) {
          // STRICT GUARDRAIL
          final cleanedText = state.text.trim();
          if (cleanedText.isEmpty ||
              cleanedText.toLowerCase() == "no text found" ||
              cleanedText.contains('لا يوجد نص')) {
            // Scenario 1: Failure / No Text
            // STOP! Do NOT navigate to the Editor page.
            // Action: Stay on the ScannerPage.
            // Action: Trigger the redesigned "Faded Ink" failure overlay
            _handleError();
          } else {
            // Scenario 2: Success
            // Only NOW navigate to the Editor/Review page with the extracted text.
            Navigator.pop(context, state.text);
          }
        } else if (state is ScannerFailure) {
          _handleError();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFBF7), // Creamy paper background
        body: SafeArea(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _hasError ? _buildErrorView() : _buildLoadingView(),
            ),
          ),
        ),
      ),
    );
  }

  void _handleError() {
    setState(() {
      _hasError = true;
    });

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pop(context, false);
      }
    });
  }

  Widget _buildLoadingView() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lottie Animation
        SizedBox(
          width: 300.w(context),
          height: 300.h(context),
          child: Lottie.asset(
            'assets/lottie/Document OCR Scan.json',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 32.h(context)),

        // Brand-Aligned Title
        Text(
          'جاري استنطاق الحروف..',
          style: GoogleFonts.tajawal(
            fontSize: 22.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue, // Deep Jalees Blue
            height: 1.2,
          ),
        ),
        SizedBox(height: 12.h(context)),

        // Brand-Aligned Subtitle
        Text(
          'نحول الصورة إلى كلمات..',
          style: GoogleFonts.tajawal(
            fontSize: 16.sp(context),
            fontWeight: FontWeight.w500,
            color: AppColors.primaryBrown, // Warm Brown
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        key: const ValueKey('error'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "Faded Ink" Icon Concept with Animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Faded Page - Pulse Animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeInOut,
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: Opacity(
                      opacity: 0.3 * (2 - val), // Fades slightly as it expands
                      child: Icon(
                        Icons.article_outlined,
                        size: 90.sp(context), // Slightly larger
                        color: AppColors.primaryBrown,
                      ),
                    ),
                  );
                },
                onEnd:
                    () {}, // Could loop but one-shot is cleaner for short state
              ),

              // Broken Pen - Shake Animation (Error)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 3.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticIn,
                builder: (context, val, child) {
                  // Simple shake math: sin(val * pi) * amplitude
                  final offset = (val < 3 && val > 0)
                      ? (10 * (1 - (val / 3)) * (val % 2 == 0 ? 1 : -1))
                      : 0.0;
                  // Actually let's use a cleaner sine shake
                  double shake = 0;
                  if (val < 2.5) {
                    shake = 10 *
                        dart_math.sin(val * 4 * dart_math.pi) *
                        (1 - val / 3);
                  }

                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: child,
                  );
                },
                child: Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8.r(context)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFBF7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBrown.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit_off_rounded,
                      size: 32.sp(context),
                      color: AppColors.primaryBrown,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h(context)),

          // Title
          Text(
            'يبدو حبر الصفحة خافتاً..',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 20.sp(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue, // Consistent header color
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h(context)),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w(context)),
            child: Text(
              'لم يستطع جليس قراءة السطور.\nحاول بزاوية أوضح أو إضاءة أفضل.',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 16.sp(context),
                fontWeight: FontWeight.normal,
                color: AppColors.primaryBrown, // Warm brown for body
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
