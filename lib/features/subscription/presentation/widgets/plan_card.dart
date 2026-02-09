import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/refi_gradient_button.dart';
import '../../domain/entities/plan_entity.dart';

class PlanCard extends StatelessWidget {
  final PlanEntity plan;
  final int billingPeriod; // 0: monthly, 1: 6 months, 2: yearly
  final VoidCallback onSelect;
  final bool isActive;
  final String? actionButtonLabel; // Custom label override
  final bool isActionDisabled; // Allow disabling explicitly

  const PlanCard({
    super.key,
    required this.plan,
    required this.billingPeriod,
    required this.onSelect,
    this.isActive = false,
    this.actionButtonLabel,
    this.isActionDisabled = false,
  });

  String _getBadgeText(String badge) {
    if (badge == AppStrings.mostPopular) {
      if (billingPeriod == 0) {
        return AppStrings.mostPopularMonthly;
      } else if (billingPeriod == 1) {
        return AppStrings.mostPopularSixMonths;
      } else {
        return AppStrings.mostPopularYearly;
      }
    }
    return badge;
  }

  String _getPlanName(String planName, bool isFree) {
    if (isFree) {
      return planName;
    }
    if (planName == AppStrings.planPremium) {
      if (billingPeriod == 0) {
        return AppStrings.planPremiumMonthly;
      } else if (billingPeriod == 1) {
        return AppStrings.planPremiumExtended;
      } else {
        return AppStrings.planPremiumYearly;
      }
    }
    return planName;
  }

  @override
  Widget build(BuildContext context) {
    final price = billingPeriod == 0
        ? plan.monthlyPrice
        : billingPeriod == 1
            ? plan.sixMonthsPrice
            : plan.yearlyPrice;
    final isFree = price == 0;
    final isPopular = plan.isPopular;
    final isBestValue = plan.isBestValue;

    int? discountPercent;
    if (billingPeriod == 1) {
      discountPercent = plan.sixMonthsDiscountPercent;
    } else if (billingPeriod == 2) {
      discountPercent = plan.yearlyDiscountPercent;
    }

    // Check if it's a trial badge
    final isTrial = plan.badge?.contains('تجربة') ?? false;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r(context)),
            border: Border.all(
              color: isPopular || isActive
                  ? AppColors.primaryBlue
                  : AppColors.inputBorder,
              width: isPopular || isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isPopular || isActive
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius:
                    isPopular || isActive ? 20.r(context) : 16.r(context),
                offset: Offset(
                    0, isPopular || isActive ? 8.h(context) : 4.h(context)),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              if (plan.badge != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: 20.h(context),
                    left: 20.w(context),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w(context),
                        vertical: 6.h(context),
                      ),
                      decoration: BoxDecoration(
                        gradient: isBestValue || isTrial
                            ? AppColors.refiMeshGradient
                            : LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.secondaryBlue,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12.r(context)),
                      ),
                      child: Text(
                        _getBadgeText(plan.badge!),
                        style: TextStyle(
                          fontSize: 12.sp(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Name and Badge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(
                                builder: (context) {
                                  final planName =
                                      _getPlanName(plan.name, isFree);
                                  String svgPath;
                                  if (planName == AppStrings.planBasic) {
                                    svgPath = 'assets/images/جليس.svg';
                                  } else if (billingPeriod == 0) {
                                    svgPath = 'assets/images/جليس شهري.svg';
                                  } else if (billingPeriod == 1) {
                                    svgPath = 'assets/images/جليس ممتد.svg';
                                  } else {
                                    svgPath = 'assets/images/جليس سنوي.svg';
                                  }
                                  return SvgPicture.asset(
                                    svgPath,
                                    height: 40.h(context),
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerLeft,
                                  );
                                },
                              ),
                              SizedBox(height: 4.h(context)),
                              Text(
                                plan.description,
                                style: TextStyle(
                                  fontSize: 14.sp(context),
                                  color: AppColors.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h(context)),

                    // Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (plan.originalPriceString != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                plan.originalPriceString!,
                                style: TextStyle(
                                  fontSize: 16.sp(context),
                                  color:
                                      AppColors.textSub.withValues(alpha: 0.4),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.black87,
                                  decorationThickness: 2.5,
                                ),
                              ),
                              if (discountPercent != null) ...[
                                SizedBox(width: 8.w(context)),
                                Transform.translate(
                                  offset: Offset(0, -2.h(context)),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w(context),
                                      vertical: 4.h(context),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryBlue,
                                      borderRadius:
                                          BorderRadius.circular(8.r(context)),
                                    ),
                                    child: Text(
                                      'خصم $discountPercent%',
                                      style: TextStyle(
                                        fontSize: 12.sp(context),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4.h(context)),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              isFree
                                  ? AppStrings.free
                                  : (plan.priceString ??
                                      '${price.toStringAsFixed(2)}'),
                              style: TextStyle(
                                fontSize: 32.sp(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                                height: 1,
                              ),
                            ),
                            // SVGs Removed - Currency is in the string
                          ],
                        ),
                        if (!isFree)
                          Text(
                            billingPeriod == 0
                                ? '/ شهرياً'
                                : billingPeriod == 1
                                    ? '/ 6 أشهر'
                                    : '/ سنوياً',
                            style: TextStyle(
                              fontSize: 14.sp(context),
                              color: AppColors.textPlaceholder,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 24.h(context)),

                    // Features List
                    ...plan.features.map((feature) {
                      final isNote = feature.contains('ملاحظة:');
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h(context)),
                        child: isNote
                            ? Container(
                                padding: EdgeInsets.all(12.w(context)),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(12.r(context)),
                                  border: Border.all(
                                    color: AppColors.primaryBlue
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18.sp(context),
                                      color: AppColors.primaryBlue,
                                    ),
                                    SizedBox(width: 8.w(context)),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: TextStyle(
                                          fontSize: 14.sp(context),
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 4.h(context),
                                      left: 8.w(context),
                                    ),
                                    width: 20.w(context),
                                    height: 20.h(context),
                                    decoration: BoxDecoration(
                                      color: AppColors.successGreen
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 14.sp(context),
                                      color: AppColors.successGreen,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        fontSize: 14.sp(context),
                                        color: AppColors.textMain,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }),

                    // Action Button
                    if (!isFree) ...[
                      SizedBox(height: 24.h(context)),
                      isActionDisabled
                          ? Container(
                              width: double.infinity,
                              height: 56.h(context),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius:
                                    BorderRadius.circular(16.r(context)),
                              ),
                              child: Center(
                                child: Text(
                                  actionButtonLabel ?? 'خطتك الحالية',
                                  style: TextStyle(
                                    fontSize: 16.sp(context),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            )
                          : RefiGradientButton(
                              text: actionButtonLabel ?? 'ترقية الباقة',
                              onPressed: onSelect,
                              height: 56,
                            ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
