import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ImageSourceOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Container(
          padding: EdgeInsets.all(20.w(context)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w(context)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
                child: Icon(
                  icon,
                  size: 24.sp(context),
                  color: color,
                ),
              ),
              SizedBox(width: 16.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.tajawal(
                        fontSize: 16.sp(context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      subtitle,
                      style: GoogleFonts.tajawal(
                        fontSize: 12.sp(context),
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18.sp(context),
                color: AppColors.textSub,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
