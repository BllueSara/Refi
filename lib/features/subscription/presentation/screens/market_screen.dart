import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/plan_entity.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/services/subscription_manager.dart';
import '../../../../core/di/injection_container.dart';
import '../widgets/plan_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _selectedBillingPeriod = 0; // 0: monthly, 1: 6 months, 2: yearly
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Offerings? _offerings;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    setState(() => _isLoading = true);
    final offerings = await sl<SubscriptionManager>().getOfferings();
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _isLoading = false;
      });
    }
  }

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
    return Stack(
      children: [
        Scaffold(
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
            actions: [
              IconButton(
                icon: Icon(
                  Icons.bug_report,
                  color: AppColors.textMain,
                  size: 24.sp(context),
                ),
                onPressed: _testRevenueCat,
                tooltip: 'اختبار RevenueCat',
              ),
            ],
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
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          ),
      ],
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

  Future<void> _handlePlanSelection(PlanEntity plan) async {
    // Only process for premium plan
    if (plan.id != 'premium') {
      // For basic plan, maybe just show a message or do nothing as it's active by default
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أهلاً بك في باقة ${plan.name}'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      return;
    }

    if (_offerings?.current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('عذراً، الاشتراكات غير متاحة حالياً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Package? packageToPurchase;
    // Map billing period to RevenueCat package
    switch (_selectedBillingPeriod) {
      case 0: // Monthly
        packageToPurchase = _offerings?.current?.monthly;
        break;
      case 1: // 6 Months
        packageToPurchase = _offerings?.current?.sixMonth;
        break;
      case 2: // Yearly
        packageToPurchase = _offerings?.current?.annual;
        break;
    }

    if (packageToPurchase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('هذه الباقة غير متاحة حالياً على المتجر'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success =
          await sl<SubscriptionManager>().purchasePackage(packageToPurchase);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم الاشتراك بنجاح! استمتع بمميزات جليس بلس'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          // Optional: Navigate away or refresh state
        }
      } else {
        // success == false means cancelled (or active but issue with entitlement logic)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إلغاء عملية الاشتراك'),
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Error is already logged in manager, show generic error to user or handled inside manager rethrows
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الاشتراك: حاول مرة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testRevenueCat() async {
    setState(() => _isLoading = true);

    try {
      final manager = sl<SubscriptionManager>();

      // Get all test information
      final isInitialized = manager.isInitialized;
      final isPremium = await manager.isUserPremium();
      final customerInfo = await manager.getCustomerInfo();
      final offerings = await manager.getOfferings();

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show test results dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('نتائج اختبار RevenueCat'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTestRow(
                    '✅ التهيئة', isInitialized ? 'نعم' : 'لا', isInitialized),
                const SizedBox(height: 12),
                _buildTestRow(
                    '💎 حالة الاشتراك', isPremium ? 'مميز' : 'عادي', isPremium),
                const SizedBox(height: 12),
                _buildTestRow(
                    '📦 الـ Offerings',
                    offerings?.current != null ? 'متاحة' : 'غير متاحة',
                    offerings?.current != null),
                const SizedBox(height: 12),
                if (offerings?.current != null) ...[
                  _buildTestRow(
                      '  - شهري',
                      offerings!.current!.monthly != null ? 'متاح' : 'غير متاح',
                      offerings.current!.monthly != null),
                  _buildTestRow(
                      '  - 6 أشهر',
                      offerings.current!.sixMonth != null ? 'متاح' : 'غير متاح',
                      offerings.current!.sixMonth != null),
                  _buildTestRow(
                      '  - سنوي',
                      offerings.current!.annual != null ? 'متاح' : 'غير متاح',
                      offerings.current!.annual != null),
                  const SizedBox(height: 12),
                ],
                if (customerInfo != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'معلومات المستخدم:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.sp(context)),
                  ),
                  const SizedBox(height: 8),
                  Text('User ID: ${customerInfo.originalAppUserId}',
                      style: TextStyle(fontSize: 12.sp(context))),
                  const SizedBox(height: 4),
                  Text(
                      'Entitlements: ${customerInfo.entitlements.all.keys.join(", ")}',
                      style: TextStyle(fontSize: 12.sp(context))),
                  const SizedBox(height: 4),
                  Text(
                      'Active Subscriptions: ${customerInfo.activeSubscriptions.length}',
                      style: TextStyle(fontSize: 12.sp(context))),
                ],
              ],
            ),
          ),
          actions: [
            if (!isInitialized)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  try {
                    await manager.init();
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تهيئة RevenueCat بنجاح!'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                      // Retry test
                      _testRevenueCat();
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('فشل التهيئة: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
                child: const Text('إعادة تهيئة RevenueCat'),
              ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  final restored = await manager.restorePurchases();
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(restored
                            ? 'تم استعادة الاشتراك بنجاح'
                            : 'لا توجد اشتراكات للاستعادة'),
                        backgroundColor:
                            restored ? AppColors.successGreen : Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ في الاستعادة: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('استعادة الاشتراكات'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('❌ Error in _testRevenueCat: $e');
        debugPrint('   Stack trace: $stackTrace');

        // Show detailed error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('خطأ في الاختبار'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حدث خطأ أثناء اختبار RevenueCat:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('$e'),
                  const SizedBox(height: 16),
                  if (e.toString().contains('MissingPluginException') ||
                      e.toString().contains('No implementation found')) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ المشكلة: الـ Plugin غير مربوط!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'هذا يحدث عادة عند استخدام Hot Reload بدلاً من Full Restart.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'الحلول المقترحة:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. أوقف التطبيق بالكامل (Stop)'),
                  const Text('2. شغّل: flutter clean'),
                  const Text('3. شغّل: flutter pub get'),
                  const Text('4. شغّل: flutter run (Full Restart)'),
                  const SizedBox(height: 8),
                  const Text(
                    'ملاحظة: Hot Reload لا يعمل مع Native Plugins!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  try {
                    await sl<SubscriptionManager>().init();
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تهيئة RevenueCat بنجاح!'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                      _testRevenueCat();
                    }
                  } catch (initError) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('فشل التهيئة: $initError'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
                child: const Text('إعادة تهيئة RevenueCat'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildTestRow(String label, String value, bool isSuccess) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: 8.w(context), vertical: 4.h(context)),
          decoration: BoxDecoration(
            color: isSuccess
                ? AppColors.successGreen.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r(context)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp(context),
              color: isSuccess ? AppColors.successGreen : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
