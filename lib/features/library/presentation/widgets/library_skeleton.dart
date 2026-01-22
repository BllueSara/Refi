import 'package:flutter/material.dart';
import '../../../../core/widgets/refi_skeleton.dart';

class LibrarySkeleton extends StatelessWidget {
  const LibrarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs Skeleton
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              RefiSkeleton(width: 80, height: 40, radius: 24),
              SizedBox(width: 12),
              RefiSkeleton(width: 80, height: 40, radius: 24),
              SizedBox(width: 12),
              RefiSkeleton(width: 80, height: 40, radius: 24),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: RefiSkeleton(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 24,
                    ),
                  ),
                  SizedBox(height: 12),
                  RefiSkeleton(width: 100, height: 16),
                  SizedBox(height: 8),
                  RefiSkeleton(width: 60, height: 12),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
