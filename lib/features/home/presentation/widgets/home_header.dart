import 'package:flutter/material.dart';
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
              const SizedBox(height: 4),
              // Streak Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.secondaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${data.streakDays} ${AppStrings.streakSuffix}",
                      style: const TextStyle(
                        //fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryBlue,
                      ),
                    ),
                  ],
                ),
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
  Size get preferredSize => const Size.fromHeight(80);
}
