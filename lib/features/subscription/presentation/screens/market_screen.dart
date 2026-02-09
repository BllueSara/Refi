import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  // Helper function to get currency symbol
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'SAR':
        return 'ر.س';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currencyCode; // Return code if symbol not found
    }
  }

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
      final customerInfo = await Purchases.restorePurchases();
      // Update local state based on customerInfo
      final isPro = customerInfo.entitlements.all['premium']?.isActive ?? false;

      if (mounted) {
        setState(() => _isLoading = false);

        if (isPro) {
          _activePlanId = await sl<SubscriptionManager>().getActivePlanId();
          _fetchData();
        }

        RestoreStatusDialog.show(context, isSuccess: isPro);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Handle Receipt Already In Use specifically if needed,
        // though usually restorePurchases just transfers or fails silently on some errors.
        // However, for "Switching Accounts", the user might use Purchases.logIn which might throw.
        // But here we are doing Restore.
        SubscriptionErrorHandler.showPurchaseError(context, e);
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

          // If this was a trial purchase (annual plan with trial), mark it as used
          if (_selectedBillingPeriod == 2 && _isTrialEligible) {
            await _markTrialAsUsed();
            _isTrialEligible = false; // Update state
          }

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
          // Trial should only be available once per year (not per plan)
          final annualPackage = offering.annual;
          if (annualPackage != null) {
            // Check if user has used trial in the past year
            final hasUsedTrialInPastYear = await _hasUsedTrialInPastYear();
            
            if (!hasUsedTrialInPastYear) {
              final eligibilityMap = await sl<SubscriptionManager>()
                  .checkTrialEligibility([annualPackage.storeProduct.identifier]);
              final eligibility =
                  eligibilityMap[annualPackage.storeProduct.identifier];

              // Update trial eligibility state - only if not used in past year
              _isTrialEligible = eligibility?.status ==
                  IntroEligibilityStatus.introEligibilityStatusEligible;
              debugPrint(
                  'Trial Eligibility for ${annualPackage.storeProduct.identifier}: $_isTrialEligible');
            } else {
              _isTrialEligible = false;
              debugPrint('Trial not eligible: User has used trial in the past year');
            }
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

    // Formatting currency: Pick currency code from ANY available package to ensure consistency
    final anyProduct = monthly ?? annual ?? sixMonth;
    final currencyCode = anyProduct?.storeProduct.currencyCode ?? 'SAR';
    // Use the actual currency code from the product, not default to USD
    // For original price formatting, use the same currency as the product
    final currencyFormatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: 2,
      locale: currencyCode == 'SAR' ? 'ar_SA' : 'en_US',
    );

    // badge Logic - التجربة المجانية فقط للباقة السنوية
    String? trialBadge;
    // Only show trial badge for annual plan (yearly) - NOT for monthly or 6 months
    if (_selectedBillingPeriod == 2 && annual != null && _isTrialEligible) {
      trialBadge = "تجربة مجانية 7 أيام";
    }

    // Determine current Display Price String based on selection
    String? displayPriceString;
    String? displayOriginalPriceString;
    String? badgeText; // Secondary badge or Main Badge logic?
    // Using main badge field in PlanEntity for the top-right badge.

    if (_selectedBillingPeriod == 0) {
      // Monthly - لا تجربة مجانية للباقة الشهرية
      displayPriceString = monthly?.storeProduct.priceString;
      displayOriginalPriceString = null;
      badgeText = "الأكثر مرونة";
    } else if (_selectedBillingPeriod == 1) {
      // 6 Months - لا تجربة مجانية لباقة 6 أشهر
      displayPriceString = sixMonth?.storeProduct.priceString;
      // Original for 6 months = Monthly * 6
      displayOriginalPriceString = currencyFormatter.format(monthlyPrice * 6);
      badgeText = "قيمة ممتازة";
    } else {
      // Yearly - التجربة المجانية فقط للباقة السنوية
      displayPriceString = annual?.storeProduct.priceString;
      // Original for Yearly = Monthly * 12
      displayOriginalPriceString = currencyFormatter.format(monthlyPrice * 12);

      // Show trial badge only for yearly plan
      if (trialBadge != null && _isTrialEligible) {
        badgeText = trialBadge;
      } else {
        badgeText = "الأكثر توفيراً";
      }
    }

    setState(() {
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
          // التجربة المجانية تظهر فقط في الباقة السنوية (badgeText يحتوي على trialBadge فقط للباقة السنوية)
          badge: badgeText,
          priceString: displayPriceString,
          originalPriceString: displayOriginalPriceString,
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
        onTap: () {
          setState(() {
            _selectedBillingPeriod = index;
            if (_offerings != null) {
              final offering = _offerings!.all['base'] ?? _offerings!.current;
              if (offering != null) {
                _updatePlansWithOfferings(offering);
              }
            }
          });
        },
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
            // Check if it's an upgrade/downgrade vs just different billing
            buttonText = 'تغيير الباقة';
          } else {
            // No active plan -> fresh purchase or trial
            // CONDITIONAL LOGIC: FREE TRIAL ONLY FOR YEARLY (Annual)
            if (_selectedBillingPeriod == 2 && _isTrialEligible) {
              buttonText = 'ابدأ اسبوعك المجاني';
            } else {
              buttonText = 'اشترك الآن';
            }
          }
        }
      }
    }

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

  // Check if user has used trial in the past year
  Future<bool> _hasUsedTrialInPastYear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trialUsedTimestamp = prefs.getInt('trial_used_timestamp');
      
      if (trialUsedTimestamp == null) {
        return false; // Never used trial
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneYearInMs = 365 * 24 * 60 * 60 * 1000; // 1 year in milliseconds
      
      // Check if trial was used within the past year
      return (now - trialUsedTimestamp) < oneYearInMs;
    } catch (e) {
      debugPrint('Error checking trial usage: $e');
      return false; // Default to allowing trial if check fails
    }
  }

  // Mark trial as used
  Future<void> _markTrialAsUsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('trial_used_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error marking trial as used: $e');
    }
  }
}
