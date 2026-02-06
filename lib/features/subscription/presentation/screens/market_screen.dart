import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/plan_entity.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/services/subscription_manager.dart';
import '../../../../core/services/subscription_error_handler.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/refi_success_widget.dart';
import '../widgets/plan_card.dart';
import '../widgets/cancellation_modal.dart';
import '../widgets/restore_status_dialog.dart';
import '../../../../core/widgets/literary_overlay.dart';
import 'legal_template_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _selectedBillingPeriod = 1; // Default to 6 months
  bool _isLoading = false;
  String _loadingMessage = '';
  Offerings? _offerings;
  String? _activePlanId;
  bool _isTrialEligible = false;

  // Default plans
  List<PlanEntity> _plans = [
    const PlanEntity(
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
    const PlanEntity(
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
  void initState() {
    super.initState();
    _fetchData();
  }

  // ...

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6), // Slightly darker for focus
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24.r(context)),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7), // Creamy/Paper background
            borderRadius: BorderRadius.circular(16.r(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
              SizedBox(height: 16.h(context)),
              Text(
                _loadingMessage.isEmpty ? 'جاري التحميل..' : _loadingMessage,
                style: GoogleFonts.tajawal(
                  fontSize: 14.sp(context),
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'جاري البحث في السجلات..'; // Searching records...
    });

    try {
      final isPro = await sl<SubscriptionManager>().restorePurchases();

      if (mounted) {
        setState(() => _isLoading = false);

        _activePlanId = await sl<SubscriptionManager>().getActivePlanId();
        _fetchData();

        RestoreStatusDialog.show(context, isSuccess: isPro);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SubscriptionErrorHandler.showPurchaseError(context, e);
      }
    }
  }

  Future<void> _handlePlanSelection(PlanEntity plan, bool isDisabled) async {
    if (isDisabled) return;
    if (plan.id == 'basic') return;

    final offering = _offerings?.all['base'] ?? _offerings?.current;

    if (offering == null) {
      LiteraryOverlay.show(context,
          message: 'عذراً، الاشتراكات غير متاحة حالياً', isError: true);
      return;
    }

    Package? packageToPurchase;
    switch (_selectedBillingPeriod) {
      case 0:
        packageToPurchase = offering.monthly;
        break;
      case 1:
        packageToPurchase = offering.sixMonth;
        break;
      case 2:
        packageToPurchase = offering.annual;
        break;
    }

    if (packageToPurchase == null) {
      LiteraryOverlay.show(context,
          message: 'هذه الباقة غير متاحة حالياً على المتجر', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'جاري تأكيد الاشتراك..';
    });

    try {
      final success =
          await sl<SubscriptionManager>().purchasePackage(packageToPurchase);
      if (success) {
        if (mounted) {
          setState(() => _isLoading = false);
          _activePlanId = await sl<SubscriptionManager>().getActivePlanId();

          final planName = _getPlanNameForBillingPeriod();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RefiSuccessWidget(
                title: 'تم الاشتراك بنجاح!',
                subtitle: 'استمتع بمميزات $planName',
                primaryButtonLabel: 'متابعة',
                onPrimaryAction: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
          _fetchData();
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          CancellationModal.show(
            context,
            onClose: () => Navigator.of(context).pop(),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SubscriptionErrorHandler.showPurchaseError(context, e);
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    // Fetch active plan
    _activePlanId = await sl<SubscriptionManager>().getActivePlanId();

    // Fetch offerings
    final offerings = await sl<SubscriptionManager>().getOfferings();

    if (mounted) {
      if (offerings != null) {
        debugPrint('Available Offerings Keys: ${offerings.all.keys.toList()}');
        debugPrint('Current Offering ID: ${offerings.current?.identifier}');

        final offering = offerings.all['base'] ?? offerings.current;
        if (offering != null) {
          debugPrint('Using Offering: ${offering.identifier}');

          // Check Trial Eligibility for Annual Plan
          final annualPackage = offering.annual;
          if (annualPackage != null) {
            final eligibilityMap = await sl<SubscriptionManager>()
                .checkTrialEligibility([annualPackage.storeProduct.identifier]);
            final eligibility =
                eligibilityMap[annualPackage.storeProduct.identifier];

            // Update trial eligibility state
            _isTrialEligible = eligibility?.status ==
                IntroEligibilityStatus.introEligibilityStatusEligible;
            debugPrint(
                'Trial Eligibility for ${annualPackage.storeProduct.identifier}: $_isTrialEligible');
          }

          _updatePlansWithOfferings(offering);
          setState(() {
            _offerings = offerings;
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePlansWithOfferings(Offering currentOffering) {
    if (currentOffering.availablePackages.isEmpty) return;

    final monthly = currentOffering.monthly;
    final sixMonth = currentOffering.sixMonth;
    final annual = currentOffering.annual;

    if (monthly == null && annual == null && sixMonth == null) return;

    final monthlyPrice = monthly?.storeProduct.price ?? 19.99;
    final sixMonthPrice = sixMonth?.storeProduct.price ?? 99.99;
    final yearlyPrice = annual?.storeProduct.price ?? 149.99;

    // Check Trial Eligibility (Assuming Trial is on Yearly or Monthly)
    // We check the "current" selection context dynamically, but for global flag:
    // We'll check if ANY package has trial to show badge optionally
    bool hasTrial = false;
    String? trialBadge;

    // Check Annual specifically as per requirement
    if (annual != null) {
      debugPrint('Checking Annual Plan Trial Eligibility:');
      debugPrint('Make: ${annual.storeProduct.introductoryPrice?.period}');
      debugPrint('Price: ${annual.storeProduct.introductoryPrice?.price}');
      debugPrint(
          'PeriodNumberOfUnits: ${annual.storeProduct.introductoryPrice?.periodNumberOfUnits}');
      debugPrint(
          'PeriodUnit: ${annual.storeProduct.introductoryPrice?.periodUnit}');
      debugPrint('Cycles: ${annual.storeProduct.introductoryPrice?.cycles}');
      debugPrint('Full Intro Object: ${annual.storeProduct.introductoryPrice}');
    }

    if (annual != null && _isTrialEligible) {
      hasTrial = true;
      trialBadge = "تجربة مجانية 7 أيام";
    }

    setState(() {
      _isTrialEligible = hasTrial;
      _plans = [
        _plans.first, // Keep Basic
        PlanEntity(
          id: 'premium',
          name: AppStrings.planPremium,
          description: 'للقارئ النهم',
          monthlyPrice: monthlyPrice,
          sixMonthsPrice: sixMonthPrice,
          yearlyPrice: yearlyPrice,
          originalSixMonthsPrice: monthlyPrice * 6,
          originalYearlyPrice: monthlyPrice * 12,
          sixMonthsDiscountPercent: 17,
          yearlyDiscountPercent: 37,
          features: const [
            'كتب غير محدودة',
            'الهدف السنوي متاح',
            'اقتباسات يدوية: غير محدودة',
            'اقتباسات بالتصوير: غير محدودة',
            'الملاحظات والشعور متاحة مع كل اقتباس',
            'ملاحظة: المميزات الجديدة تشملها',
          ],
          isPopular: true,
          badge: trialBadge ?? AppStrings.mostPopular,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h(context)),
                  _buildSubtitle(),
                  SizedBox(height: 32.h(context)),
                  _buildBillingToggle(),
                  SizedBox(height: 32.h(context)),
                  ..._plans.map((plan) => _buildPlanCard(plan)),
                  SizedBox(height: 32.h(context)),
                  _buildFooterLinks(),
                  SizedBox(height: 16.h(context)),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
        TextButton(
          onPressed: _restorePurchases,
          child: Text(
            'استعادة',
            style: GoogleFonts.tajawal(
              fontSize: 14.sp(context),
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: Text(
        'يمكنك تغيير أو إلغاء اشتراكك في أي وقت.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp(context),
          color: AppColors.textSub,
          height: 1.5,
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
          _buildToggleOption(0, AppStrings.monthly),
          _buildToggleOption(1, AppStrings.sixMonths),
          _buildToggleOption(2, AppStrings.yearly),
        ],
      ),
    );
  }

  Widget _buildToggleOption(int index, String text) {
    final isSelected = _selectedBillingPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedBillingPeriod = index),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 12.h(context),
            horizontal: 8.w(context),
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r(context)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8.r(context),
                      offset: Offset(0, 2.h(context)),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryBlue : AppColors.textSub,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(PlanEntity plan) {
    bool isActive = false;
    String? buttonText;
    bool isActionDisabled = false;

    // Check if subscription logic matches
    if (plan.id == 'premium') {
      final offering = _offerings?.all['base'] ?? _offerings?.current;
      if (offering != null) {
        String? selectedPackageId;
        Package? selectedPackage;

        switch (_selectedBillingPeriod) {
          case 0:
            selectedPackage = offering.monthly;
            break;
          case 1:
            selectedPackage = offering.sixMonth;
            break;
          case 2:
            selectedPackage = offering.annual;
            break;
        }
        selectedPackageId = selectedPackage?.storeProduct.identifier;

        if (selectedPackageId != null && selectedPackageId == _activePlanId) {
          isActive = true;
          buttonText = 'خطتك الحالية';
          isActionDisabled = true;
        } else {
          // Not active plan
          if (_activePlanId != null) {
            // If some other plan is active, this is an upgrade
            buttonText = 'ترقية الباقة';
          } else {
            // No active plan -> fresh purchase or trial
            if (selectedPackage != null && _isTrialEligible) {
              buttonText = 'ابدئي أسبوعكِ المجاني';
            } else {
              buttonText = 'اشتركي الآن';
            }
          }
        }
      }
    }

    // Force isActive false for PlanCard to remove legacy "Subscribed" badge logic if any remained
    // handled by buttonText and isActionDisabled
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h(context)),
      child: PlanCard(
        plan: plan,
        billingPeriod: _selectedBillingPeriod,
        isActive: isActive,
        actionButtonLabel: buttonText,
        isActionDisabled: isActionDisabled,
        onSelect: () => _handlePlanSelection(plan, isActionDisabled),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegalLink(
          "سياسة الخصوصية",
          "https://raw.githubusercontent.com/BllueSara/jalees-legal/refs/heads/main/privacy.md",
        ),
        Container(
          height: 12.h(context),
          width: 1,
          color: AppColors.textSub,
          margin: EdgeInsets.symmetric(horizontal: 16.w(context)),
        ),
        _buildLegalLink(
          "شروط الاستخدام",
          "https://raw.githubusercontent.com/BllueSara/jalees-legal/refs/heads/main/terms.md",
        ),
      ],
    );
  }

  Widget _buildLegalLink(String title, String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LegalTemplateScreen(
              title: title,
              markdownUrl: url,
            ),
          ),
        );
      },
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 12.sp(context),
          color: AppColors.textSub,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  String _getPlanNameForBillingPeriod() {
    switch (_selectedBillingPeriod) {
      case 0:
        return AppStrings.planPremiumMonthly;
      case 1:
        return AppStrings.planPremiumExtended;
      case 2:
        return AppStrings.planPremiumYearly;
      default:
        return AppStrings.planPremium;
    }
  }
}
