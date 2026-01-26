import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

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
          padding: EdgeInsets.all(24.w(context)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24.r(context)),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20.r(context),
                offset: Offset(0, 10.h(context)),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(
                      0.1), // Assumes Red exists or use error color
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 32.sp(context),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SizedBox(height: 16.h(context)),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  fontSize: 22.sp(context), // Larger
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              SizedBox(height: 12.h(context)),
              Text(
                'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  //fontFamily: 'Tajawal',
                  fontSize: 16.sp(context),
                  color: AppColors.textSub,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h(context)),
              Row(
                children: [
                  // Cancel Button -> Blue Gradient
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.refiMeshGradient,
                        borderRadius: BorderRadius.circular(12.r(context)),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r(context)),
                          ),
                        ),
                        child: Text(
                          'تراجع',
                          style: TextStyle(
                            //fontFamily: 'Tajawal',
                            fontSize: 16.sp(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w(context)),

                  // Logout Button -> Simple Red Text
                  Expanded(
                    child: TextButton(
                      onPressed: onLogout,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r(context)),
                        ),
                      ),
                      child: Text(
                        'خروج',
                        style: TextStyle(
                          //fontFamily: 'Tajawal',
                          fontSize: 16.sp(context),
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
