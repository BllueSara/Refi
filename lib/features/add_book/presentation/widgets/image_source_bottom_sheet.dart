import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'image_source_option.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onWebSearch;
  final VoidCallback onGalleryPick;
  final VoidCallback onCameraPick;

  const ImageSourceBottomSheet({
    super.key,
    required this.onWebSearch,
    required this.onGalleryPick,
    required this.onCameraPick,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onWebSearch,
    required VoidCallback onGalleryPick,
    required VoidCallback onCameraPick,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r(context)),
        ),
      ),
      builder: (context) {
        return ImageSourceBottomSheet(
          onWebSearch: onWebSearch,
          onGalleryPick: onGalleryPick,
          onCameraPick: onCameraPick,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.h(context),
        bottom: MediaQuery.of(context).padding.bottom + 20.h(context),
        left: 24.w(context),
        right: 24.w(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w(context),
            height: 4.h(context),
            decoration: BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: BorderRadius.circular(2.r(context)),
            ),
          ),
          SizedBox(height: 24.h(context)),
          // Title
          Text(
            "اختر مصدر غلاف الكتاب",
            style: GoogleFonts.tajawal(
              fontSize: 20.sp(context),
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            "يمكنك اختيار صورة من الإنترنت أو من جهازك",
            style: GoogleFonts.tajawal(
              fontSize: 13.sp(context),
              color: AppColors.textSub,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h(context)),
          // Options
          ImageSourceOption(
            icon: Icons.search_rounded,
            title: "بحث في الإنترنت",
            subtitle: "ابحث عن غلاف الكتاب عبر الإنترنت",
            color: AppColors.primaryBlue,
            onTap: () {
              Navigator.pop(context);
              onWebSearch();
            },
          ),
          SizedBox(height: 16.h(context)),
          ImageSourceOption(
            icon: Icons.photo_library_rounded,
            title: "معرض الصور",
            subtitle: "اختر صورة من معرض الصور",
            color: AppColors.primaryBlue,
            onTap: () {
              Navigator.pop(context);
              onGalleryPick();
            },
          ),
          SizedBox(height: 16.h(context)),
          ImageSourceOption(
            icon: Icons.camera_alt_rounded,
            title: "الكاميرا",
            subtitle: "التقط صورة باستخدام الكاميرا",
            color: AppColors.secondaryBlue,
            onTap: () {
              Navigator.pop(context);
              onCameraPick();
            },
          ),
        ],
      ),
    );
  }
}
