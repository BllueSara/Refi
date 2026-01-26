import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileEntity? profile;
  final String? email;

  const ProfileHeader({super.key, this.profile, this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100.w(context),
          height: 100.h(context),
          padding: EdgeInsets.all(3.w(context)),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.refiMeshGradient,
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: EdgeInsets.all(2.w(context)),
            child: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              backgroundImage: (profile?.avatarUrl != null)
                  ? NetworkImage(profile!.avatarUrl!)
                  : const NetworkImage(
                      "https://i.pravatar.cc/300?img=5",
                    ), // Fallback/Placeholder
              radius: 46.r(context),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.paddingM.h(context)),

        // Name and Edit
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile?.fullName ?? AppStrings.userNamePlaceholder,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: AppDimensions.paddingS.w(context)),
            GestureDetector(
              onTap: () {
                // Edit Profile Logic
              },
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.refiMeshGradient.createShader(bounds),
                child: Icon(Icons.edit, size: 20.sp(context), color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h(context)),
        Text(
          email ?? AppStrings.userEmailPlaceholder,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
