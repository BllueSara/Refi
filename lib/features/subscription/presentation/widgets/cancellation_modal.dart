import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

/// A modal popup widget that appears when a subscription operation is cancelled.
///
/// This modal is designed to:
/// - Overlay the paywall screen with a blurred background
/// - Display a friendly cancellation message in Arabic
/// - Provide options to return to plans or dismiss
///
/// Usage:
/// ```dart
/// CancellationModal.show(context);
/// ```
class CancellationModal extends StatefulWidget {
  /// Callback when user taps "إغلاق" (Close)
  final VoidCallback? onClose;

  const CancellationModal({
    super.key,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onClose,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CancellationModal(
          onClose: onClose ?? () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CancellationModal> createState() => _CancellationModalState();
}

class _CancellationModalState extends State<CancellationModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Blurred background overlay
          GestureDetector(
            onTap: widget.onClose ?? () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),

          // Centered modal card
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w(context)),
                  padding: EdgeInsets.all(24.w(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.r(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30.r(context),
                        offset: Offset(0, 10.h(context)),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10.r(context),
                          offset: Offset(0, 4.h(context))),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Warning Icon
                      _buildWarningIcon(context),
                      SizedBox(height: 20.h(context)),

                      // Title
                      _buildTitle(context),
                      SizedBox(height: 12.h(context)),

                      // Body Text
                      _buildBodyText(context),
                      SizedBox(height: 28.h(context)),

                      // Close Button
                      _buildCloseButton(context),
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

  Widget _buildWarningIcon(BuildContext context) {
    return Container(
      width: 64.w(context),
      height: 64.w(context),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.warning_amber_rounded,
          size: 32.sp(context),
          color: AppColors.warningOrange,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'تم إلغاء العملية',
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 20.sp(context),
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildBodyText(BuildContext context) {
    return Text(
      'لم يتم تفعيل أي اشتراك، ولن يتم خصم أي مبلغ من بطاقتك.\nيمكنك دائمًا العودة لاحقًا والاشتراك في جليس متى ما رغبت.',
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 15.sp(context),
        height: 1.6,
        color: AppColors.textSub,
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52.h(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r(context)),
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryBlue, // #1E3A8A
            AppColors.secondaryBlue, // #3B82F6
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12.r(context),
            offset: Offset(0, 4.h(context)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onClose ?? () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(14.r(context)),
          child: Center(
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16.sp(context),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
