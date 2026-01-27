import 'package:flutter/material.dart';
import '../../../../core/widgets/refi_skeleton.dart';
import '../../../../core/utils/responsive_utils.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 16.h(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton (Matches AppBar/Header area roughly, though AppBar is usually separate)
          // Since HomePage has AppBar separate, this body starts below it. Not typically including AppBar here.
          // But user wants "exact shape".

          // Hero Quote Card Skeleton (Matches HomeHeroQuote)
          Container(
            width: double.infinity,
            height: 220.h(context), // Approx height of quote card
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r(context)),
              color: Colors.white,
            ),
            child: RefiSkeleton(
              width: double.infinity,
              height: 220.h(context),
              radius: 24.r(context),
            ),
          ),

          SizedBox(height: 32.h(context)),

          // Stats Label
          RefiSkeleton(width: 80.w(context), height: 24.h(context)),
          SizedBox(height: 16.h(context)),

          // Stats Grid (Matches StatCard layout)
          Row(
            children: [
              Expanded(child: _buildStatCardSkeleton(context)),
              SizedBox(width: 12.w(context)),
              Expanded(child: _buildStatCardSkeleton(context)),
              SizedBox(width: 12.w(context)),
              Expanded(child: _buildStatCardSkeleton(context)),
            ],
          ),

          SizedBox(height: 32.h(context)),

          // Currently Reading Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RefiSkeleton(width: 100.w(context), height: 24.h(context)),
              RefiSkeleton(width: 60.w(context), height: 16.h(context)),
            ],
          ),
          SizedBox(height: 16.h(context)),

          // Reading List (Matches BookCard)
          SizedBox(
            height: 140.h(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 16.w(context)),
              itemBuilder: (context, index) {
                return _buildBookCardSkeleton(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardSkeleton(BuildContext context) {
    return Container(
      height: 100.h(context), // Approx stat card height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r(context)),
        // color: Colors.white, // Handled by shimmer
      ),
      child: RefiSkeleton(
        width: double.infinity,
        height: 100.h(context),
        radius: 16.r(context),
      ),
    );
  }

  Widget _buildBookCardSkeleton(BuildContext context) {
    return SizedBox(
      width: 100.w(context), // Matches BookCard width typically
      child: Column(
        children: [
          RefiSkeleton(width: 100.w(context), height: 110.h(context), radius: 16.r(context)), // Cover
          SizedBox(height: 8.h(context)),
          RefiSkeleton(width: 80.w(context), height: 12.h(context)), // Title
        ],
      ),
    );
  }
}
