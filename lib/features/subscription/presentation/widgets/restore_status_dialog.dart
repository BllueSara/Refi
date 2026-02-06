import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class RestoreStatusDialog extends StatelessWidget {
  final bool isSuccess;
  final VoidCallback onDismiss;

  const RestoreStatusDialog({
    super.key,
    required this.isSuccess,
    required this.onDismiss,
  });

  static void show(BuildContext context, {required bool isSuccess}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => RestoreStatusDialog(
        isSuccess: isSuccess,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(24.w(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(16.w(context)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess
                    ? const Color(0xFFE3F2FD) // Soft Blue
                    : const Color(0xFFFFEBEE), // Soft Red/Orange
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.info_rounded,
                size: 48.sp(context),
                color:
                    isSuccess ? AppColors.primaryBlue : const Color(0xFFD32F2F),
              ),
            ),
            SizedBox(height: 24.h(context)),

            // Title
            Text(
              isSuccess ? 'أهلاً بعودتك' : 'لم نجد اشتراكاً',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 20.sp(context),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 12.h(context)),

            // Message
            Text(
              isSuccess
                  ? 'تم استعادة رحلتك المعرفية بنجاح.'
                  : 'لم يتم العثور على اشتراكات سابقة لهذا الحساب.',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 15.sp(context),
                height: 1.6,
                color: AppColors.textSub,
              ),
            ),
            SizedBox(height: 32.h(context)),

            // Gradient Button
            Container(
              width: double.infinity,
              height: 50.h(context),
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(16.r(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(16.r(context)),
                  child: Center(
                    child: Text(
                      'حسناً',
                      style: GoogleFonts.tajawal(
                        fontSize: 16.sp(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
