import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/plan_entity.dart';
import '../widgets/plan_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _selectedBillingPeriod = 0; // 0: monthly, 1: 6 months, 2: yearly
  final TextEditingController _searchController = TextEditingController();

  // Mock plans data
  final List<PlanEntity> _plans = const [
    PlanEntity(
      id: 'basic',
      name: AppStrings.planBasic,
      description: 'مثالية للبدء',
      monthlyPrice: 0,
      sixMonthsPrice: 0,
      yearlyPrice: 0,
      features: [
        'كتب غير محدودة',
        'الهدف السنوي متاح',
        'اقتباسات يدوية: 15 حد أقصى',
        'اقتباسات بالتصوير: 15 حد أقصى',
        'الملاحظات والشعور متاحة مع كل اقتباس',
      ],
    ),
    PlanEntity(
      id: 'premium',
      name: AppStrings.planPremium,
      description: 'للقارئ النهم',
      monthlyPrice: 19.99,
      sixMonthsPrice: 99.99,
      yearlyPrice: 149.99,
      originalSixMonthsPrice: 119.94,
      originalYearlyPrice: 239.88,
      sixMonthsDiscountPercent: 17,
      yearlyDiscountPercent: 37,
      features: [
        'كتب غير محدودة',
        'الهدف السنوي متاح',
        'اقتباسات يدوية: غير محدودة',
        'اقتباسات بالتصوير: غير محدودة',
        'الملاحظات والشعور متاحة مع كل اقتباس',
        'ملاحظة: المميزات الجديدة تشملها',
      ],
      isPopular: true,
      badge: AppStrings.mostPopular,
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
              ..._plans.map((plan) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h(context)),
                  child: PlanCard(
                    plan: plan,
                    billingPeriod: _selectedBillingPeriod,
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
              onTap: () => setState(() => _selectedBillingPeriod = 0),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12.h(context),
                  horizontal: 8.w(context),
                ),
                decoration: BoxDecoration(
                  color: _selectedBillingPeriod == 0
                      ? AppColors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r(context)),
                  boxShadow: _selectedBillingPeriod == 0
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
                    fontSize: 13.sp(context),
                    fontWeight: _selectedBillingPeriod == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedBillingPeriod == 0
                        ? AppColors.primaryBlue
                        : AppColors.textSub,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedBillingPeriod = 1),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12.h(context),
                  horizontal: 8.w(context),
                ),
                decoration: BoxDecoration(
                  color: _selectedBillingPeriod == 1
                      ? AppColors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r(context)),
                  boxShadow: _selectedBillingPeriod == 1
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
                  AppStrings.sixMonths,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp(context),
                    fontWeight: _selectedBillingPeriod == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedBillingPeriod == 1
                        ? AppColors.primaryBlue
                        : AppColors.textSub,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedBillingPeriod = 2),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12.h(context),
                  horizontal: 8.w(context),
                ),
                decoration: BoxDecoration(
                  color: _selectedBillingPeriod == 2
                      ? AppColors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r(context)),
                  boxShadow: _selectedBillingPeriod == 2
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
                  AppStrings.yearly,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp(context),
                    fontWeight: _selectedBillingPeriod == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedBillingPeriod == 2
                        ? AppColors.primaryBlue
                        : AppColors.textSub,
                  ),
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
