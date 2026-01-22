import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// A pill-shaped bottom bar with a raised center dot and center cutout,
/// matching the provided design.
class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({
    super.key,
    this.items = const <BottomNavBarItem>[],
    this.barColor = AppColors.white,
    this.barGradient,
    this.dotColor = AppColors.primaryBlue,
    this.dotGradient,
    this.dotBorderColor = Colors.transparent,
    this.dotBorderWidth = 0,
    this.dotOuterSize = 62,
    this.dotInnerSize = 54,
    this.itemColor = AppColors.textMain,
    this.labelStyle = const TextStyle(
      color: AppColors.textMain,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    this.barHeight = 52,
    this.horizontalPadding = 0,
    this.itemsHorizontalPadding = 26,
    this.itemSpacing = 24,
    this.gapBetweenDotAndCutout = 0,
    // Position circle slightly lower; increase this to push further down
    this.dotVerticalOffset = -50,
    this.onDotTap,
    this.dotIcon,
    this.dotLabel,
    this.dotIconColor = Colors.white,
    this.dotLabelStyle,
    this.currentIndex,
    this.dotActiveIndex = 2,
    this.selectedDotColor,
    this.selectedDotIconColor,
  });

  final List<BottomNavBarItem> items;
  final Color barColor;
  final Gradient? barGradient;
  final Color dotColor;
  final Gradient? dotGradient;
  final Color dotBorderColor;
  final double dotBorderWidth;
  final double dotOuterSize;
  final double dotInnerSize;
  final Color itemColor;
  final TextStyle labelStyle;
  final double barHeight;
  final double horizontalPadding;
  final double itemsHorizontalPadding;
  final double itemSpacing;
  final double gapBetweenDotAndCutout;
  final double dotVerticalOffset;
  final VoidCallback? onDotTap;
  final IconData? dotIcon;
  final String? dotLabel;
  final Color dotIconColor;
  final TextStyle? dotLabelStyle;
  final int? currentIndex;

  /// The tab index when the dot should appear as selected.
  /// Defaults to 2 (Scanner tab).
  final int dotActiveIndex;

  /// Color of the dot when selected. If null, uses dotColor.
  final Color? selectedDotColor;

  /// Color of the dot icon when selected. If null, uses dotIconColor.
  final Color? selectedDotIconColor;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveBarColor = isDarkMode ? AppColors.textMain : barColor;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // تحديد إذا كان الجهاز كبير (tablet) أو صغير (phone)
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    final double scaleFactor =
        isTablet ? 2.0 : 1.0; // تكبير 100% على الأجهزة الكبيرة

    // تطبيق التكبير على الأبعاد
    final double scaledBarHeight = barHeight * scaleFactor;
    final double scaledDotOuterSize = dotOuterSize * scaleFactor;
    final double scaledDotInnerSize = dotInnerSize * scaleFactor;
    final double scaledHorizontalPadding = horizontalPadding * scaleFactor;
    final double scaledItemsHorizontalPadding =
        itemsHorizontalPadding * scaleFactor;
    final double scaledDotVerticalOffset = dotVerticalOffset * scaleFactor;

    final double totalHeight = scaledBarHeight +
        scaledDotOuterSize / 2 +
        scaledDotVerticalOffset +
        14 * scaleFactor +
        bottomPadding; // shadows + safe area
    final double cutoutRadius =
        (scaledDotOuterSize / 2 + gapBetweenDotAndCutout * scaleFactor)
            .clamp(0, double.infinity);
    // cutoutCenterDy from top of CustomPaint (bar is at bottom: 0)
    // When dotVerticalOffset is negative, it means move down from the top of the bar
    // So cutoutCenterDy from top of CustomPaint = barHeight + dotVerticalOffset
    final double cutoutCenterDyInPainter =
        scaledBarHeight + scaledDotVerticalOffset;
    // Dot center from top of Stack = (totalHeight - barHeight) + cutoutCenterDyInPainter
    final double cutoutCenterDyFromTop =
        (totalHeight - scaledBarHeight - bottomPadding) +
            cutoutCenterDyInPainter;
    // Dot position from top of Stack
    final double dotTop = cutoutCenterDyFromTop - scaledDotOuterSize / 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20 * (isTablet ? 1.15 : 1.0),
          width: double.infinity,
        ),
        SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: scaledHorizontalPadding,
                right: scaledHorizontalPadding,
                bottom: 0,
                child: isDarkMode
                    ? Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, -5),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _BarWithCutoutPainter(
                            color: effectiveBarColor,
                            gradient: barGradient,
                            barHeight: scaledBarHeight + bottomPadding,
                            cutoutRadius: cutoutRadius,
                            cutoutCenterDy: cutoutCenterDyInPainter,
                            isDarkMode: isDarkMode,
                          ),
                          child: SizedBox(
                            height: scaledBarHeight + bottomPadding,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: scaledItemsHorizontalPadding,
                                right: scaledItemsHorizontalPadding,
                                bottom: bottomPadding,
                              ),
                              child: _buildItemsRow(context, scaleFactor),
                            ),
                          ),
                        ),
                      )
                    : CustomPaint(
                        painter: _BarWithCutoutPainter(
                          color: effectiveBarColor,
                          gradient: barGradient,
                          barHeight: scaledBarHeight + bottomPadding,
                          cutoutRadius: cutoutRadius,
                          cutoutCenterDy: cutoutCenterDyInPainter,
                          isDarkMode: isDarkMode,
                        ),
                        child: SizedBox(
                          height: scaledBarHeight + bottomPadding,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: scaledItemsHorizontalPadding,
                              right: scaledItemsHorizontalPadding,
                              bottom: bottomPadding,
                            ),
                            child: _buildItemsRow(context, scaleFactor),
                          ),
                        ),
                      ),
              ),
              Positioned(
                top: dotTop,
                child: GestureDetector(
                  onTap: onDotTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: const Cubic(0.25, 0.1, 0.25, 1.0),
                    width: scaledDotOuterSize,
                    height: scaledDotOuterSize,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.22),
                          blurRadius: 5.55,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: dotBorderWidth > 0
                          ? Border.all(
                              color: dotBorderColor,
                              width: dotBorderWidth,
                            )
                          : null,
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: const Cubic(0.25, 0.1, 0.25, 1.0),
                        width: scaledDotInnerSize,
                        height: scaledDotInnerSize,
                        decoration: BoxDecoration(
                          gradient: dotGradient ??
                              ((currentIndex != null &&
                                      currentIndex == dotActiveIndex)
                                  ? AppColors.refiMeshGradient
                                  : null),
                          color: dotGradient == null
                              ? ((currentIndex != null &&
                                      currentIndex == dotActiveIndex)
                                  ? (selectedDotColor ?? dotColor)
                                  : dotColor)
                              : null,
                          shape: BoxShape.circle,
                          border: (currentIndex != null &&
                                  currentIndex == dotActiveIndex)
                              ? Border.all(
                                  color: Colors.white,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: dotIcon != null
                            ? AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Icon(
                                  dotIcon,
                                  key: ValueKey(
                                      '${dotIcon}_${currentIndex == dotActiveIndex}'),
                                  color: (currentIndex != null &&
                                          currentIndex == dotActiveIndex)
                                      ? (selectedDotIconColor ?? dotIconColor)
                                      : dotIconColor,
                                  size: scaledDotInnerSize * 0.5,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsRow(BuildContext context, double scaleFactor) {
    final List<Widget> children = [];
    final int totalItems = items.length;
    final int leftItems = totalItems ~/ 2;

    Widget buildItem(int index) {
      final item = items[index];
      // Use tabIndex if provided, otherwise use the item's index in the list
      final int effectiveIndex = item.tabIndex ?? index;
      final isSelected = currentIndex == effectiveIndex;
      return Expanded(
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16 * scaleFactor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 4 * scaleFactor),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: isSelected
                    ? ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.refiMeshGradient.createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: Icon(
                          item.activeIcon ?? item.icon,
                          key: ValueKey('${item.icon}_$isSelected'),
                          color: Colors.white,
                          size:
                              24 * scaleFactor, // Slightly larger when selected
                        ),
                      )
                    : Icon(
                        item.icon,
                        key: ValueKey('${item.icon}_$isSelected'),
                        color: itemColor,
                        size: 22 * scaleFactor,
                      ),
              ),
              SizedBox(height: 4 * scaleFactor),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: const Cubic(0.4, 0.0, 0.2, 1.0),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    item.label,
                    key: ValueKey('${item.label}_$isSelected'),
                    style: labelStyle.copyWith(
                      fontSize: (labelStyle.fontSize ?? 12) * scaleFactor,
                      fontWeight:
                          isSelected ? FontWeight.bold : labelStyle.fontWeight,
                      color:
                          isSelected ? AppColors.primaryBlue : labelStyle.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Left side items
    for (var i = 0; i < leftItems; i++) {
      children.add(buildItem(i));
    }

    // Center dot label
    if (dotLabel != null) {
      final bool isDotSelected =
          currentIndex != null && currentIndex == dotActiveIndex;
      final TextStyle effectiveLabelStyle =
          (dotLabelStyle ?? labelStyle).copyWith(
        fontSize: ((dotLabelStyle ?? labelStyle).fontSize ?? 12) * scaleFactor,
        color: isDotSelected && selectedDotIconColor != null
            ? selectedDotIconColor
            : (dotLabelStyle ?? labelStyle).color,
      );
      children.add(SizedBox(width: 8 * scaleFactor));
      children.add(
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 24 * scaleFactor),
              SizedBox(height: 10 * scaleFactor),
              Text(
                dotLabel!,
                style: effectiveLabelStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
      children.add(SizedBox(width: 8 * scaleFactor));
    }

    // Right side items
    for (var i = leftItems; i < totalItems; i++) {
      children.add(buildItem(i));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
}

class BottomNavBarItem {
  const BottomNavBarItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.activeIcon,
    this.tabIndex,
  });

  final IconData icon; // Outlined icon (default)
  final IconData? activeIcon; // Filled icon (when selected)
  final String label;
  final VoidCallback? onTap;

  /// The tab index this item corresponds to in the tabs list.
  /// If null, uses the item's position in the items list.
  final int? tabIndex;
}

class _BarWithCutoutPainter extends CustomPainter {
  _BarWithCutoutPainter({
    required this.color,
    this.gradient,
    required this.barHeight,
    required this.cutoutRadius,
    required this.cutoutCenterDy,
    this.isDarkMode = false,
  });

  final Color color;
  final Gradient? gradient;
  final double barHeight;
  final double cutoutRadius;
  final double cutoutCenterDy;
  final bool isDarkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final rectPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width, barHeight),
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
        ),
      );

    final cutoutPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, cutoutCenterDy),
          radius: cutoutRadius,
        ),
      );

    final barPath =
        Path.combine(PathOperation.difference, rectPath, cutoutPath);

    // Shadow - stronger in dark mode
    if (isDarkMode) {
      // Multiple shadows for better elevation effect in dark mode
      canvas.drawShadow(
        barPath.shift(const Offset(0, 8)),
        Colors.black.withOpacity(0.6),
        20,
        true,
      );
      canvas.drawShadow(
        barPath.shift(const Offset(0, 4)),
        Colors.black.withOpacity(0.4),
        12,
        true,
      );
      canvas.drawShadow(
        barPath.shift(const Offset(0, 2)),
        Colors.black.withOpacity(0.3),
        6,
        true,
      );
    } else {
      // Original shadow for light mode
      canvas.drawShadow(
        barPath.shift(const Offset(0, 15)),
        Colors.black.withOpacity(0.5),
        15.35,
        true,
      );
    }

    // Fill
    final paint = Paint();
    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, barHeight),
      );
    } else {
      paint.color = color;
    }
    canvas.drawPath(barPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BarWithCutoutPainter oldDelegate) {
    return color != oldDelegate.color ||
        gradient != oldDelegate.gradient ||
        barHeight != oldDelegate.barHeight ||
        cutoutRadius != oldDelegate.cutoutRadius ||
        cutoutCenterDy != oldDelegate.cutoutCenterDy ||
        isDarkMode != oldDelegate.isDarkMode;
  }
}
