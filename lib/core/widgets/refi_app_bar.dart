import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../utils/responsive_utils.dart';

class RefiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback? onSearchTap;

  const RefiAppBar({
    super.key,
    required this.searchController,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      titleSpacing: AppSizes.p24.w(context),
      title: Container(
        height: 48.h(context),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius.r(context)),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: TextField(
          controller: searchController,
          onTap: onSearchTap,
          textAlign: TextAlign.right, // RTL
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 14.sp(context),
            ////fontFamily: 'Tajawal',
          ),
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            hintStyle: TextStyle(
              color: AppColors.textPlaceholder,
              fontSize: 14.sp(context),
              ////fontFamily: 'Tajawal',
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.textPlaceholder, size: 20.sp(context)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.p16.w(context),
              vertical: 12.h(context),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
