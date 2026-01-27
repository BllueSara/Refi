import 'package:flutter/material.dart';
import '../../../../core/widgets/refi_skeleton.dart';
import '../../../../core/utils/responsive_utils.dart';

class LibrarySkeleton extends StatelessWidget {
  const LibrarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs Skeleton
        Container(
          height: 50.h(context),
          margin: EdgeInsets.symmetric(vertical: 16.h(context)),
          padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
          child: Row(
            children: [
              RefiSkeleton(width: 80.w(context), height: 40.h(context), radius: 24.r(context)),
              SizedBox(width: 12.w(context)),
              RefiSkeleton(width: 80.w(context), height: 40.h(context), radius: 24.r(context)),
              SizedBox(width: 12.w(context)),
              RefiSkeleton(width: 80.w(context), height: 40.h(context), radius: 24.r(context)),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16.w(context)),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16.w(context),
              mainAxisSpacing: 24.h(context),
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RefiSkeleton(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 24.r(context),
                    ),
                  ),
                  SizedBox(height: 12.h(context)),
                  RefiSkeleton(width: 100.w(context), height: 16.h(context)),
                  SizedBox(height: 8.h(context)),
                  RefiSkeleton(width: 60.w(context), height: 12.h(context)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
