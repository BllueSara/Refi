import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class SaveBookButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isEdit;

  const SaveBookButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.h(context),
      decoration: BoxDecoration(
        gradient: AppColors.refiMeshGradient,
        borderRadius: BorderRadius.circular(20.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 20.r(context),
            offset: Offset(0, 8.h(context)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(20.r(context)),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isEdit ? Icons.check_circle_rounded : Icons.add_circle_rounded,
                  size: 22.sp(context),
                  color: AppColors.white,
                ),
                SizedBox(width: 10.w(context)),
                Text(
                  label,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp(context),
                    color: AppColors.white,
                    letterSpacing: 0.5,
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
