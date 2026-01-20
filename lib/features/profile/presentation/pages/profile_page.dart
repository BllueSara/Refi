import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_option_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.profileTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: AppDimensions.paddingXL),

            // Settings List
            ProfileOptionTile(
              title: AppStrings.annualGoal,
              showArrow: true,
              trailing: Text(
                AppStrings.annualGoalValue,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              onTap: () {
                // Open Annual Goal Edit
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ProfileOptionTile(
              title: AppStrings.changePassword,
              showArrow: true,
              onTap: () {
                // Change Password logic
              },
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ProfileOptionTile(
              title: AppStrings.readingNotifications,
              showArrow: false,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveThumbColor: Colors.white,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ProfileOptionTile(
              title: AppStrings.aboutRefi,
              showArrow: true,
              onTap: () {
                // Show About
              },
            ),

            const SizedBox(height: AppDimensions.paddingXXL),

            // Logout
            TextButton(
              onPressed: () {
                // Logout Logic
              },
              child: Text(
                AppStrings.logout,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              AppStrings.appVersion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
