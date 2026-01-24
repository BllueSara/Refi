import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CustomLogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const CustomLogoutDialog({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(
                      0.1), // Assumes Red exists or use error color
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 32,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  fontSize: 22, // Larger
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: AppColors.textSub,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Cancel Button -> Blue Gradient
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.refiMeshGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تراجع',
                          style: TextStyle(
                            //fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Logout Button -> Simple Red Text
                  Expanded(
                    child: TextButton(
                      onPressed: onLogout,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'خروج',
                        style: TextStyle(
                          //fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
