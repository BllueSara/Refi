import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';

class RefiButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSecondary;
  final IconData? icon;
  final bool isLoading;

  const RefiButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSecondary = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : AppColors.primaryBlue,
          foregroundColor: isSecondary ? AppColors.textMain : Colors.white,
          elevation: isSecondary ? 0 : 4,
          shadowColor:
              isSecondary ? null : AppColors.primaryBlue.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: isSecondary
                ? const BorderSide(color: AppColors.inputBorder)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isSecondary ? AppColors.primaryBlue : Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      //fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
