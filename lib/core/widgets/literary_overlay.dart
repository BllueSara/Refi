import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/responsive_utils.dart';

class LiteraryOverlay {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = true, // true = Error/Warning, false = Info/Success
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _LiteraryToastWidget(
        message: message,
        isError: isError,
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after duration
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }
}

class _LiteraryToastWidget extends StatefulWidget {
  final String message;
  final bool isError;

  const _LiteraryToastWidget({
    required this.message,
    required this.isError,
  });

  @override
  State<_LiteraryToastWidget> createState() => _LiteraryToastWidgetState();
}

class _LiteraryToastWidgetState extends State<_LiteraryToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    // Reverse animation before removing is handled by the parent finding a way?
    // Actually OverlayEntry.remove() is abrupt.
    // For a smoother exit, we'd need a more complex setup or a dismissal callback.
    // For now, we'll just fade in beautifully.
    // To fade out, we'd need to trigger reverse() before the parent calls remove().
    // We can do self-dismissal logic here if we passed the entry, but simple is better.
    // Let's settle for a nice entry animation.
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60.h(context),
      left: 20.w(context),
      right: 20.w(context),
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w(context),
                vertical: 16.h(context),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7), // Creamy paper color
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBrown.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  // Paper texture effect (subtle inner shadow)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                    spreadRadius: -2,
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon as a "Stamp"
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isError
                          ? const Color(0xFF8D6E63)
                              .withOpacity(0.1) // Muted Brown
                          : AppColors.primaryBlue.withOpacity(0.1),
                    ),
                    child: Icon(
                      widget.isError
                          ? Icons.history_edu_rounded
                          : Icons.auto_awesome,
                      color: widget.isError
                          ? const Color(0xFF8D6E63)
                          : AppColors.primaryBlue,
                      size: 24.sp(context),
                    ),
                  ),
                  SizedBox(width: 16.w(context)),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isError ? "رسالة من جليس" : "تم بنجاح",
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12.sp(context),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h(context)),
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14.sp(context),
                            color: AppColors.textMain,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
