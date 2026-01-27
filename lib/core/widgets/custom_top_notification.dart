import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../utils/responsive_utils.dart';

class CustomTopNotification extends StatefulWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onDismiss;

  const CustomTopNotification({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.onDismiss,
  });

  @override
  State<CustomTopNotification> createState() => _CustomTopNotificationState();
}

class _CustomTopNotificationState extends State<CustomTopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto dismiss
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) widget.onDismiss!();
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
      top: MediaQuery.of(context).padding.top + 16.h(context),
      left: 16.w(context),
      right: 16.w(context),
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w(context),
                vertical: 12.h(context),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r(context)),
                border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.15),
                    blurRadius: 20.r(context),
                    offset: Offset(0, 10.h(context)),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Action Button (Left - LTR context, but logic RTL)
                  TextButton(
                    onPressed: () {
                      _dismiss();
                      widget.onAction();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(50.w(context), 30.h(context)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      widget.actionLabel,
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp(context),
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),

                  // Message & Icon (Right)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            widget.message,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp(context),
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w(context)),
                        Icon(
                          Icons.info_rounded,
                          color: AppColors.primaryBlue,
                          size: 20.sp(context),
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

// Helper to show overlay
void showCustomTopNotification(
  BuildContext context, {
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => CustomTopNotification(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: () {
        overlayEntry?.remove();
        overlayEntry = null;
      },
    ),
  );

  Overlay.of(context).insert(overlayEntry!);
}
