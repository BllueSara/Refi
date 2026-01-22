import 'package:flutter/material.dart';
import '../constants/colors.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSuccess ? AppColors.refiMeshGradient : null,
            color: isSuccess
                ? null
                : (isError ? AppColors.errorRed : AppColors.warningOrange),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    (isSuccess
                            ? AppColors.primaryBlue
                            : (isError
                                  ? AppColors.errorRed
                                  : AppColors.warningOrange))
                        .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
