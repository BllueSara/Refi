import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/colors.dart';
import '../utils/responsive_utils.dart';
import 'refi_gradient_button.dart';

class NoInternetDialog extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetDialog({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r(context)),
      ),
      child: Builder(
        builder: (context) => Container(
          padding: EdgeInsets.all(24.w(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Animation
              SizedBox(
                height: 200.h(context),
                width: 200.w(context),
                child: Lottie.asset(
                  'assets/images/no internet.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              SizedBox(height: 16.h(context)),

              // Title
              Text(
                'لا يوجد اتصال بالإنترنت',
                style: TextStyle(
                  fontSize: 20.sp(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h(context)),

              // Message
              Text(
                'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
                style: TextStyle(
                  fontSize: 14.sp(context),
                  color: AppColors.textSub,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h(context)),

              // Retry Button
              if (onRetry != null)
                RefiGradientButton(
                  text: 'إعادة المحاولة',
                  onPressed: onRetry!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context, {VoidCallback? onRetry}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoInternetDialog(onRetry: onRetry),
    );
  }
}
