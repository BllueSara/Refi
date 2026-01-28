import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../quotes/presentation/widgets/quote_review_modal.dart';
import '../cubit/scanner_cubit.dart';

class ScanningProcessingPage extends StatelessWidget {
  final String imagePath;

  const ScanningProcessingPage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerCubit, ScannerState>(
      listener: (context, state) {
        if (state is ScannerSuccess) {
          // Close this processing page
          Navigator.pop(context);
          // Show the quote review modal
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: QuoteReviewModal(initialText: state.text),
            ),
          );
        } else if (state is ScannerFailure) {
          // Close this processing page
          Navigator.pop(context);
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
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
                // Processing Text
                Text(
                  'جاري معالجة النص...',
                  style: TextStyle(
                    fontSize: 20.sp(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(height: 12.h(context)),
                Text(
                  'الرجاء الانتظار',
                  style: TextStyle(
                    fontSize: 16.sp(context),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

