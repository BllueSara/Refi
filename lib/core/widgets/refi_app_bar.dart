import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

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
      titleSpacing: AppSizes.p24,
      title: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: TextField(
          controller: searchController,
          onTap: onSearchTap,
          textAlign: TextAlign.right, // RTL
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: AppStrings.searchHint,
            hintStyle: TextStyle(
              color: AppColors.textPlaceholder,
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.textPlaceholder),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 14,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
