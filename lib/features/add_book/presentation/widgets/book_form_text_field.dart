import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class BookFormTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool isNumber;
  final String? Function(String?)? validator;

  const BookFormTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.isNumber = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18.sp(context),
              color: AppColors.primaryBlue,
            ),
            SizedBox(width: 8.w(context)),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 14.sp(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h(context)),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: validator,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          style: GoogleFonts.tajawal(
            fontSize: 16.sp(context),
            color: AppColors.textMain,
          ),
          onTap: () => HapticFeedback.selectionClick(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.tajawal(
              fontSize: 14.sp(context),
              color: AppColors.textPlaceholder,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.only(right: 12.w(context)),
              padding: EdgeInsets.all(12.w(context)),
              child: Icon(
                icon,
                size: 20.sp(context),
                color: AppColors.textPlaceholder,
              ),
            ),
            // Proper Error Styling
            errorStyle: GoogleFonts.tajawal(
              fontSize: 12.sp(context),
              fontWeight: FontWeight.w500,
              color: AppColors.errorRed,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r(context)),
              borderSide: BorderSide(color: AppColors.errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r(context)),
              borderSide: BorderSide(color: AppColors.errorRed, width: 2),
            ),
            // Default Styling
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w(context),
              vertical: 18.h(context),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r(context)),
              borderSide: BorderSide(
                color: AppColors.inputBorder.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r(context)),
              borderSide: BorderSide(
                color: AppColors.inputBorder.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r(context)),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
