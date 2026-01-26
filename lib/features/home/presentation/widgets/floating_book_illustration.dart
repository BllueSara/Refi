import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class FloatingBookIllustration extends StatefulWidget {
  const FloatingBookIllustration({super.key});

  @override
  State<FloatingBookIllustration> createState() =>
      _FloatingBookIllustrationState();
}

class _FloatingBookIllustrationState extends State<FloatingBookIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160.h(context),
      width: 160.w(context),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Background Large Blob (Soft Glow)
          Positioned(
            top: 10.h(context),
            right: 10.w(context),
            child: Container(
              width: 100.w(context),
              height: 100.h(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.08),
              ),
            ),
          ),

          // 2. Geometric Shape: Hollow Circle
          Positioned(
            bottom: 25.h(context),
            left: 25.w(context),
            child: Container(
              width: 18.w(context),
              height: 18.h(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondaryBlue.withOpacity(0.3),
                  width: 2.w(context),
                ),
              ),
            ),
          ),

          // 3. Geometric Shape: The "X"
          Positioned(
            top: 25.h(context),
            left: 35.w(context),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Icon(
                Icons.add_rounded,
                size: 24.sp(context),
                color: AppColors.warningOrange.withOpacity(0.4),
              ),
            ),
          ),

          // 4. Geometric Shape: Small Solid Dot
          Positioned(
            bottom: 40.h(context),
            right: 25.w(context),
            child: Container(
              width: 8.w(context),
              height: 8.h(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.2),
              ),
            ),
          ),

          // 5. The Floating Book
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 80.w(context),
              height: 110.h(context),
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12.r(context)),
                  bottomRight: Radius.circular(12.r(context)),
                  topLeft: Radius.circular(3.r(context)),
                  bottomLeft: Radius.circular(3.r(context)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 15.r(context),
                    offset: Offset(0, 8.h(context)),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Book Spine
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 10.w(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(3.r(context)),
                          bottomLeft: Radius.circular(3.r(context)),
                        ),
                      ),
                    ),
                  ),
                  // Cover Detail (Curve)
                  Positioned(
                    right: 6.w(context),
                    top: 0,
                    bottom: 0,
                    width: 3.w(context),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Icon
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(8.w(context)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Icon(
                        Icons.bookmark_outline_rounded,
                        color: Colors.white,
                        size: 24.sp(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
