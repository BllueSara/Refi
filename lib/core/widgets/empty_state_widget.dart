import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive_utils.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon; // Optional for backward compatibility
  final String? lottieAsset; // Lottie animation path
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? activeTab; // For dynamic animations based on tab

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.icon,
    this.lottieAsset,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.activeTab,
  });

  // Get Lottie asset based on active tab or provided asset
  String? get _lottiePath {
    if (lottieAsset != null) return lottieAsset;

    // Dynamic Lottie based on tab context
    switch (activeTab) {
      case AppStrings.tabReading:
        return 'assets/images/books.json'; // Book flipping animation
      case AppStrings.tabCompleted:
        return 'assets/images/Success.json'; // Trophy/success animation
      case AppStrings.tabWishlist:
        return 'assets/images/search imm.json'; // Search/magnifying glass
      default:
        return 'assets/images/books.json'; // Default book animation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w(context),
            vertical: 16.h(context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Lottie Animation with Zero Background - Reduced size
              if (_lottiePath != null)
                SizedBox(
                  width: 200.w(context),
                  height: 200.h(context),
                  child: Lottie.asset(
                    _lottiePath!,
                    fit: BoxFit.contain,
                    // No background container - completely transparent
                    // Colors will blend with theme background
                  ),
                )
              else if (icon != null)
                // Fallback to icon if Lottie not available (backward compatibility)
                Container(
                  padding: EdgeInsets.all(20.w(context)),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Zero gray policy
                    borderRadius: BorderRadius.circular(28.r(context)),
                  ),
                  child: Icon(
                    icon!,
                    size: 56.sp(context),
                    color: AppColors.primaryBlue.withOpacity(0.6),
                  ),
                ),

              SizedBox(height: 20.h(context)),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 18.sp(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                    height: 1.3,
                  ),
                ),
              ),

              // Subtitle
              if (subtitle != null) ...[
                SizedBox(height: 8.h(context)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 14.sp(context),
                      color: AppColors.textSub,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              // Action Button
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: 24.h(context)),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.refiMeshGradient,
                    borderRadius: BorderRadius.circular(24.r(context)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 15.r(context),
                        offset: Offset(0, 6.h(context)),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r(context)),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w(context),
                        vertical: 14.h(context),
                      ),
                    ),
                    child: Text(
                      actionLabel!,
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp(context),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
