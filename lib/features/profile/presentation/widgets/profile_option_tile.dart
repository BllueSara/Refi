import 'package:flutter/material.dart';
import '../../../../core/constants/dimensions.dart';

class ProfileOptionTile extends StatelessWidget {
  final String title;
  final Widget? trailing; // Can be switch, text, or just arrow
  final VoidCallback onTap;
  final bool showArrow;

  const ProfileOptionTile({
    super.key,
    required this.title,
    required this.onTap,
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius:
              Theme.of(context).cardTheme.shape is RoundedRectangleBorder
              ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder)
                    .borderRadius
              : BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: 0.3,
                ), // Placeholder gray
              ),
          ],
        ),
      ),
    );
  }
}
