import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../constants/strings.dart';
import '../utils/responsive_utils.dart';

class CustomSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const CustomSearchAppBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: true,
      titleSpacing: AppSizes.p16.w(context),
      title: Container(
        height: 48.h(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius.r(context)),
          border: Border.all(color: AppColors.inputBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r(context),
              offset: Offset(0, 2.h(context)),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(fontSize: 13.sp(context)),
          decoration: InputDecoration(
            hintText: AppStrings.searchPlaceholder,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp(context)),
            prefixIcon:
                Icon(Icons.search, color: Colors.grey, size: 20.sp(context)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
