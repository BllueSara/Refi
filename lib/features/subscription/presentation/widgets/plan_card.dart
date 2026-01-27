import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/refi_gradient_button.dart';
import '../../domain/entities/plan_entity.dart';

class PlanCard extends StatelessWidget {
  final PlanEntity plan;
  final bool isYearly;
  final VoidCallback onSelect;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isYearly,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final isFree = price == 0;
    final isPopular = plan.isPopular;
    final isBestValue = plan.isBestValue;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r(context)),
            border: Border.all(
              color: isPopular
                  ? AppColors.primaryBlue
                  : AppColors.inputBorder,
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
                    right: 20.w(context),
                  ),
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
                      plan.badge!,
                      style: TextStyle(
                        fontSize: 12.sp(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                              Text(
                                plan.name,
                                style: TextStyle(
                                  fontSize: 24.sp(context),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isFree ? AppStrings.free : '${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32.sp(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                            height: 1,
                          ),
                        ),
                        if (!isFree) ...[
                          SizedBox(width: 4.w(context)),
                          Padding(
                            padding: EdgeInsets.only(bottom: 6.h(context)),
                            child: Text(
                              'ر.س',
                              style: TextStyle(
                                fontSize: 16.sp(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSub,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!isFree)
                      Text(
                        '/ ${isYearly ? AppStrings.yearly : AppStrings.monthly}',
                        style: TextStyle(
                          fontSize: 14.sp(context),
                          color: AppColors.textPlaceholder,
                        ),
                      ),
                    SizedBox(height: 24.h(context)),

                    // Features List
                    ...plan.features.map((feature) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h(context)),
                          child: Row(
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
                        )),
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
