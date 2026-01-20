import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.refiMeshGradient,
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              backgroundImage: const NetworkImage(
                "https://i.pravatar.cc/300?img=5",
              ),
              radius: 46,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),

        // Name and Edit
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.userNamePlaceholder,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            GestureDetector(
              onTap: () {},
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.refiMeshGradient.createShader(bounds),
                child: const Icon(Icons.edit, size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.userEmailPlaceholder,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
