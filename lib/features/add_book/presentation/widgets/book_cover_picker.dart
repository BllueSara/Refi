import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class BookCoverPicker extends StatelessWidget {
  final File? imageFile;
  final String? webImageUrl;
  final VoidCallback onTap;

  const BookCoverPicker({
    super.key,
    this.imageFile,
    this.webImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageFile != null || webImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "غلاف الكتاب",
          style: GoogleFonts.tajawal(
            fontSize: 14.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 12.h(context)),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 280.h(context),
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasImage
                  ? Colors.transparent
                  : AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20.r(context)),
              border: Border.all(
                color: hasImage
                    ? Colors.transparent
                    : AppColors.primaryBlue.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: hasImage
                  ? [
                      BoxShadow(
                        color: AppColors.textMain.withOpacity(0.1),
                        blurRadius: 20.r(context),
                        offset: Offset(0, 8.h(context)),
                      ),
                    ]
                  : null,
              image: hasImage
                  ? DecorationImage(
                      image: imageFile != null
                          ? FileImage(imageFile!) as ImageProvider
                          : NetworkImage(webImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? Stack(
                    children: [
                      // Image overlay on hover
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r(context)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.textMain.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Change image button
                      Positioned(
                        bottom: 16.h(context),
                        right: 16.w(context),
                        child: Container(
                          padding: EdgeInsets.all(12.w(context)),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12.r(context)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textMain.withOpacity(0.1),
                                blurRadius: 8.r(context),
                                offset: Offset(0, 2.h(context)),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 18.sp(context),
                                color: AppColors.primaryBlue,
                              ),
                              SizedBox(width: 6.w(context)),
                              Text(
                                "تغيير الغلاف",
                                style: GoogleFonts.tajawal(
                                  fontSize: 12.sp(context),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.w(context)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 48.sp(context),
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 20.h(context)),
                        Text(
                          AppStrings.addBookCover,
                          style: GoogleFonts.tajawal(
                            fontSize: 16.sp(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 8.h(context)),
                        Text(
                          "اضغط لإضافة صورة الغلاف",
                          style: GoogleFonts.tajawal(
                            fontSize: 12.sp(context),
                            color: AppColors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
