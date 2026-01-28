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

  const PlanCard({
    super.key,
    required this.plan,
    required this.billingPeriod,
    required this.onSelect,
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
    // الباقة المجانية تبقى "جليس" دائماً
    if (isFree) {
      return planName;
    }

    // الباقة المدفوعة تتغير حسب فترة الاشتراك
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

    String billingPeriodText;
    double? originalPrice;
    int? discountPercent;
    if (billingPeriod == 0) {
      billingPeriodText = AppStrings.monthly;
    } else if (billingPeriod == 1) {
      billingPeriodText = AppStrings.sixMonths;
      originalPrice = plan.originalSixMonthsPrice;
      discountPercent = plan.sixMonthsDiscountPercent;
    } else {
      billingPeriodText = AppStrings.yearly;
      originalPrice = plan.originalYearlyPrice;
      discountPercent = plan.yearlyDiscountPercent;
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r(context)),
            border: Border.all(
              color: isPopular ? AppColors.primaryBlue : AppColors.inputBorder,
              width: isPopular ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isPopular
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isPopular ? 20.r(context) : 16.r(context),
                offset: Offset(0, isPopular ? 8.h(context) : 4.h(context)),
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
                        gradient: isBestValue
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
                    // Plan Name & Description
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    // الباقة المجانية
                                    svgPath = 'assets/images/جليس.svg';
                                  } else if (billingPeriod == 0) {
                                    // شهري
                                    svgPath = 'assets/images/جليس شهري.svg';
                                  } else if (billingPeriod == 1) {
                                    // 6 أشهر
                                    svgPath = 'assets/images/جليس ممتد.svg';
                                  } else {
                                    // سنوي
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

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (originalPrice != null && originalPrice > price) ...[
                          // Original price (crossed out)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                originalPrice.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 16.sp(context),
                                  color:
                                      AppColors.textSub.withValues(alpha: 0.4),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.black87,
                                  decorationThickness: 2.5,
                                ),
                              ),
                              SizedBox(width: 4.w(context)),
                              Transform.translate(
                                offset: Offset(0, -5.h(context)),
                                child: SvgPicture.asset(
                                  'assets/images/Saudi_Riyal.svg',
                                  width: 16.w(context),
                                  height: 16.h(context),
                                  colorFilter: ColorFilter.mode(
                                    AppColors.textSub.withValues(alpha: 0.4),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              if (discountPercent != null) ...[
                                SizedBox(width: 8.w(context)),
                                Transform.translate(
                                  offset: Offset(0, -5.h(context)),
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
                                  : price.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 32.sp(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                                height: 1,
                              ),
                            ),
                            if (!isFree) ...[
                              SizedBox(width: 4.w(context)),
                              Transform.translate(
                                offset: Offset(0, -5.h(context)),
                                child: SvgPicture.asset(
                                  'assets/images/Saudi_Riyal.svg',
                                  width: 20.w(context),
                                  height: 20.h(context),
                                  colorFilter: ColorFilter.mode(
                                    AppColors.primaryBlue,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (!isFree)
                          Text(
                            '/ $billingPeriodText',
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
                                      color: AppColors.successGreen.withValues(
                                        alpha: 0.1,
                                      ),
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
                    SizedBox(height: 24.h(context)),

                    // Select Button
                    RefiGradientButton(
                      text: AppStrings.selectPlan,
                      onPressed: onSelect,
                      height: 56,
                    ),
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
