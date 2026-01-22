import 'package:flutter/material.dart';
import '../../../../core/widgets/refi_skeleton.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton (Matches AppBar/Header area roughly, though AppBar is usually separate)
          // Since HomePage has AppBar separate, this body starts below it. Not typically including AppBar here.
          // But user wants "exact shape".

          // Hero Quote Card Skeleton (Matches HomeHeroQuote)
          Container(
            width: double.infinity,
            height: 220, // Approx height of quote card
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            child: const RefiSkeleton(
              width: double.infinity,
              height: 220,
              radius: 24,
            ),
          ),

          const SizedBox(height: 32),

          // Stats Label
          const RefiSkeleton(width: 80, height: 24),
          const SizedBox(height: 16),

          // Stats Grid (Matches StatCard layout)
          Row(
            children: [
              Expanded(child: _buildStatCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCardSkeleton()),
            ],
          ),

          const SizedBox(height: 32),

          // Currently Reading Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              RefiSkeleton(width: 100, height: 24),
              RefiSkeleton(width: 60, height: 16),
            ],
          ),
          const SizedBox(height: 16),

          // Reading List (Matches BookCard)
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildBookCardSkeleton();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      height: 100, // Approx stat card height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // color: Colors.white, // Handled by shimmer
      ),
      child: const RefiSkeleton(
        width: double.infinity,
        height: 100,
        radius: 16,
      ),
    );
  }

  Widget _buildBookCardSkeleton() {
    return SizedBox(
      width: 100, // Matches BookCard width typically
      child: Column(
        children: const [
          RefiSkeleton(width: 100, height: 110, radius: 16), // Cover
          SizedBox(height: 8),
          RefiSkeleton(width: 80, height: 12), // Title
        ],
      ),
    );
  }
}
