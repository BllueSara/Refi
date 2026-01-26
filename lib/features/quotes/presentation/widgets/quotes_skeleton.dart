import 'package:flutter/material.dart';
import '../../../../core/widgets/refi_skeleton.dart';
import '../../../../core/utils/responsive_utils.dart';

class QuotesSkeleton extends StatelessWidget {
  const QuotesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w(context)),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: 16.h(context)),
      itemBuilder: (context, index) {
        return _buildQuoteCardSkeleton(context);
      },
    );
  }

  Widget _buildQuoteCardSkeleton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r(context)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20.r(context),
              offset: Offset(0, 8.h(context)),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote text lines
              RefiSkeleton(width: double.infinity, height: 16.h(context)),
              SizedBox(height: 8.h(context)),
              RefiSkeleton(width: double.infinity, height: 16.h(context)),
              SizedBox(height: 8.h(context)),
              RefiSkeleton(width: 200.w(context), height: 16.h(context)),
              SizedBox(height: 24.h(context)),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      RefiSkeleton(width: 24.w(context), height: 36.h(context), radius: 4.r(context)),
                      SizedBox(width: 8.w(context)),
                      RefiSkeleton(width: 100.w(context), height: 14.h(context)),
                    ],
                  ),
                  RefiSkeleton(width: 24.w(context), height: 24.h(context), radius: 12.r(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
