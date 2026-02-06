import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../widgets/literary_overlay.dart';

class SubscriptionErrorHandler {
  static void showPurchaseError(BuildContext context, dynamic error) {
    String message = 'رياح عاتية تمنعنا من الوصول.. يرجى المحاولة لاحقاً';

    if (error is PlatformException) {
      final errorCode = PurchasesErrorHelper.getErrorCode(error);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        message = 'لم يتم إكمال عملية الدفع؛ يمكنك المحاولة مجدداً في أي وقت.';
      } else if (errorCode == PurchasesErrorCode.networkError) {
        message = 'تعذر الاتصال.. يرجى التحقق من الإنترنت والمحاولة مرة أخرى.';
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        message = 'العملية قيد المعالجة.. سنقوم بتفعيل باقتك فور اكتمالها.';
      } else if (errorCode == PurchasesErrorCode.storeProblemError) {
        message =
            'واجهنا مشكلة في المتجر.. يرجى الانتظار قليلاً والمحاولة لاحقاً.';
      }
    }

    // Use the new LiteraryOverlay instead of SnackBar
    LiteraryOverlay.show(
      context,
      message: message,
      isError: true, // We treat specific messages as 'thematic' notifications
    );
  }

  static void showLimitReachedError(BuildContext context,
      {required bool isScanning}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LimitWarningSheet(isScanning: isScanning),
    );
  }
}

// Placeholder for LimitWarningSheet until it is fully implemented in its own file
class LimitWarningSheet extends StatelessWidget {
  final bool isScanning;
  const LimitWarningSheet({super.key, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    // This will be replaced by the full implementation later in the task
    return const SizedBox();
  }
}
