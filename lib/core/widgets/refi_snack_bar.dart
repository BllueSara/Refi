import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/responsive_utils.dart';

enum SnackBarType { success, error, warning }

class RefiSnackBars {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
  }) {
    final isSuccess = type == SnackBarType.success;
    final isError = type == SnackBarType.error;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w(context),
            vertical: 12.h(context),
          ),
          decoration: BoxDecoration(
            gradient: isSuccess ? AppColors.refiMeshGradient : null,
            color: isSuccess
                ? null
                : (isError ? AppColors.errorRed : AppColors.warningOrange),
            borderRadius: BorderRadius.circular(24.r(context)),
            boxShadow: [
              BoxShadow(
                color:
                    (isSuccess
                            ? AppColors.primaryBlue
                            : (isError
                                  ? AppColors.errorRed
                                  : AppColors.warningOrange))
                        .withOpacity(0.3),
                blurRadius: 12.r(context),
                offset: Offset(0, 4.h(context)),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_outline
                    : (isError ? Icons.cancel_outlined : Icons.info_outline),
                color: Colors.white,
                size: 24.sp(context),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w(context)),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
