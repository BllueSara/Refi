import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
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
                  const Text("👋", style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    "${AppStrings.hello} ${data.username}",
                    style: const TextStyle(
                      //fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
          icon: const Icon(Icons.search, color: AppColors.textMain, size: 28),
        ),
        const SizedBox(width: 16),
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
