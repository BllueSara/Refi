import 'package:flutter/material.dart';

class GradientRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  final LinearGradient gradient;

  const GradientRectSliderTrackShape({
    required this.gradient,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Assign height
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackTop =
        trackRect.top + (trackRect.height - trackHeight) / 2;
    final double trackBottom = trackTop + trackHeight;
    final Radius trackRadius = Radius.circular(trackHeight / 2);

    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = sliderTheme.activeTrackColor ?? Colors.blue;

    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.grey;

    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    // Left Track
    if (thumbCenter.dx > trackRect.left) {
      context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          trackRect.left,
          trackTop,
          thumbCenter.dx,
          trackBottom,
          topLeft: trackRadius,
          bottomLeft: trackRadius,
        ),
        leftTrackPaint,
      );
    }

    // Right Track
    if (thumbCenter.dx < trackRect.right) {
      context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          thumbCenter.dx,
          trackTop,
          trackRect.right,
          trackBottom,
          topRight: trackRadius,
          bottomRight: trackRadius,
        ),
        rightTrackPaint,
      );
    }
  }
}
