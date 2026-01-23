import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import 'scale_button.dart';

class GlassmorphicNotificationAlert extends StatefulWidget {
  final Future<void> Function()? onAction;

  const GlassmorphicNotificationAlert({
    super.key,
    this.onAction,
  });

  @override
  State<GlassmorphicNotificationAlert> createState() =>
      _GlassmorphicNotificationAlertState();
}

class _GlassmorphicNotificationAlertState
    extends State<GlassmorphicNotificationAlert> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconScaleAnimation;

  // Staggered Animations
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Entrance Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    // Staggered Text
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _textFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
    );

    // 2. Icon Breathing Controller
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Frosted Glass Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.05),
            ),
          ),
          // Modal
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.4), width: 1.5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF0F9FF).withOpacity(0.95),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Delight Animation (Breathing Icon)
                      ScaleTransition(
                        scale: _iconScaleAnimation,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEFF6FF),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Center(
                              child: Icon(Icons.bookmark_added_rounded,
                                  size: 40, color: AppColors.primaryBlue)),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Staggered Text
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                "هذا الرفيق بانتظارك!",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.tajawal(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "الكتاب موجود في مكتبتك، هل تود الانتقال لصفحته الآن؟",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.tajawal(
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Buttons Row
                      Row(
                        children: [
                          // Cancel
                          Expanded(
                            child: ScaleButton(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "إلغاء",
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Confirm
                          Expanded(
                            flex: 2,
                            child: ScaleButton(
                              onTap: () async {
                                Navigator.of(context).pop();
                                if (widget.onAction != null) {
                                  await widget.onAction!();
                                }
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF3B82F6),
                                        Color(0xFF1D4ED8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "اذهب للمكتبة",
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Function to show
void showGlassmorphicNotification(BuildContext context,
    {Future<void> Function()? onAction}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Notification",
    barrierColor:
        const Color(0xFF0F172A).withOpacity(0.4), // Dark Slate Overlay
    pageBuilder: (context, animation, secondaryAnimation) =>
        GlassmorphicNotificationAlert(onAction: onAction),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Scale & Fade Entrance
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
            scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack), // Subtle bounce on entrance
            child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}
