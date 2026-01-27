import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/refi_gradient_button.dart';
import '../../../../core/widgets/refi_app_bar.dart';
import '../../domain/entities/plan_entity.dart';
import '../widgets/plan_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  bool isYearly = false;
  final TextEditingController _searchController = TextEditingController();

  // Mock plans data
  final List<PlanEntity> _plans = const [
    PlanEntity(
      id: 'basic',
      name: AppStrings.planBasic,
      description: 'مثالية للبدء',
      monthlyPrice: 0,
      yearlyPrice: 0,
      features: [
        'حتى 50 اقتباس',
        'حتى 10 كتب',
        'مسح ضوئي أساسي',
        'تصدير PDF',
      ],
    ),
    PlanEntity(
      id: 'premium',
      name: AppStrings.planPremium,
      description: 'للقارئ النهم',
      monthlyPrice: 29.99,
      yearlyPrice: 299.99,
      features: [
        AppStrings.unlimitedQuotes,
        AppStrings.unlimitedBooks,
        AppStrings.advancedScanning,
        AppStrings.cloudBackup,
        AppStrings.exportQuotes,
        AppStrings.adFree,
      ],
      isPopular: true,
      badge: AppStrings.mostPopular,
    ),
    PlanEntity(
      id: 'pro',
      name: AppStrings.planPro,
      description: 'للمحترفين',
      monthlyPrice: 49.99,
      yearlyPrice: 499.99,
      features: [
        AppStrings.unlimitedQuotes,
        AppStrings.unlimitedBooks,
        AppStrings.advancedScanning,
        AppStrings.cloudBackup,
        AppStrings.exportQuotes,
        AppStrings.prioritySupport,
        AppStrings.customTags,
        AppStrings.analytics,
        AppStrings.adFree,
      ],
      isBestValue: true,
      badge: AppStrings.bestValue,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.marketTitle,
          style: TextStyle(
            fontSize: 20.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textMain,
            size: 24.sp(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h(context)),
              
              // Subtitle
              Center(
                child: Text(
                  AppStrings.marketSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp(context),
                    color: AppColors.textSub,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32.h(context)),

              // Billing Toggle
              _buildBillingToggle(),
              SizedBox(height: 32.h(context)),

              // Plans List
              ..._plans.asMap().entries.map((entry) {
                final index = entry.key;
                final plan = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h(context)),
                  child: PlanCard(
                    plan: plan,
                    isYearly: isYearly,
                    onSelect: () => _handlePlanSelection(plan),
                  ),
                );
              }),
              
              SizedBox(height: 32.h(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: EdgeInsets.all(4.w(context)),
      decoration: BoxDecoration(
        color: AppColors.inputBorder,
        borderRadius: BorderRadius.circular(24.r(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = false),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12.h(context),
                  horizontal: 24.w(context),
                ),
                decoration: BoxDecoration(
                  color: !isYearly ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r(context)),
                  boxShadow: !isYearly
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8.r(context),
                            offset: Offset(0, 2.h(context)),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  AppStrings.monthly,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp(context),
                    fontWeight: !isYearly ? FontWeight.bold : FontWeight.normal,
                    color: !isYearly
                        ? AppColors.primaryBlue
                        : AppColors.textSub,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = true),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12.h(context),
                  horizontal: 24.w(context),
                ),
                decoration: BoxDecoration(
                  color: isYearly ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r(context)),
                  boxShadow: isYearly
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8.r(context),
                            offset: Offset(0, 2.h(context)),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.yearly,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp(context),
                        fontWeight:
                            isYearly ? FontWeight.bold : FontWeight.normal,
                        color: isYearly
                            ? AppColors.primaryBlue
                            : AppColors.textSub,
                      ),
                    ),
                    SizedBox(width: 4.w(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w(context),
                        vertical: 2.h(context),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        borderRadius: BorderRadius.circular(8.r(context)),
                      ),
                      child: Text(
                        'توفير 20%',
                        style: TextStyle(
                          fontSize: 10.sp(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePlanSelection(PlanEntity plan) {
    // Handle plan selection logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار باقة ${plan.name}'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r(context)),
        ),
      ),
    );
  }
}
