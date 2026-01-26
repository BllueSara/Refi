import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/home_entity.dart';
import '../../../add_book/presentation/screens/search_screen.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final HomeData data;

  const HomeHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      title: Row(
        children: [
          // Greeting & Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("👋", style: TextStyle(fontSize: 20.sp(context))),
                  SizedBox(width: 8.w(context)),
                  Text(
                    "${AppStrings.hello} ${data.username}",
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp(context),
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          icon: Icon(Icons.search, color: AppColors.textMain, size: 28.sp(context)),
        ),
        SizedBox(width: 16.w(context)),
      ],
    );
  }

  @override
  Size get preferredSize {
    // Include status bar height to prevent covering the clock
    // Default AppBar height is 56, we add extra padding for status bar
    return const Size.fromHeight(kToolbarHeight + 24);
  }
}
