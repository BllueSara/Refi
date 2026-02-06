import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/quotes/domain/repositories/quote_repository.dart';
import '../di/injection_container.dart'; // for sl
import '../constants/app_strings.dart';

class SubscriptionManager {
  static const String _apiKey = 'appl_ooOghORcrXEDqgAlBsXigmKaQyh';
  static const String _entitlementID = 'jalees Pro';

  // Private constructor
  SubscriptionManager._();

  // Singleton instance
  static final SubscriptionManager instance = SubscriptionManager._();

  bool _isInitialized = false;

  // Stream controller for subscription status (CustomerInfo)
  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  // ValueNotifier for simple boolean checks (existing)
  final _isProController = ValueNotifier<bool>(false);
  ValueListenable<bool> get isProNotifier => _isProController;

  static const String _cacheKeyIsPro = 'jalees_is_pro_cache';

  /// Initialize RevenueCat
  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('✅ RevenueCat already initialized');
      return;
    }

    try {
      // 1. Load Cache Immediately
      final prefs = await SharedPreferences.getInstance();
      final cachedIsPro = prefs.getBool(_cacheKeyIsPro) ?? false;
      _isProController.value = cachedIsPro;
      debugPrint('💾 Cached Pro Status Loaded: $cachedIsPro');

      debugPrint('🔄 Starting RevenueCat initialization...');
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKey);
      } else {
        configuration = PurchasesConfiguration(_apiKey);
      }

      // 2. Configure SDK
      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('✅ RevenueCat Configured Successfully');

      // 3. Listen for updates (This handles the future updates)
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updateCustomerStatus(customerInfo);
      });

      // 4. Trace current status (Non-blocking)
      // We do NOT await this, so app startup is fast. Reference caching handles UI.
      Purchases.getCustomerInfo().then((info) => _updateCustomerStatus(info));
    } on PlatformException catch (e) {
      debugPrint('❌ PlatformException during RevenueCat init: ${e.message}');
      _isInitialized = false;
    } catch (e) {
      debugPrint('❌ Failed to configure RevenueCat: $e');
      _isInitialized = false;
    }
  }

  void _updateCustomerStatus(CustomerInfo customerInfo) async {
    // 1. Update Stream
    if (!_customerInfoController.isClosed) {
      _customerInfoController.add(customerInfo);
    }

    // 2. Update Boolean Notifier
    final isPro =
        customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    debugPrint('📢 Customer Info Updated. isPro: $isPro');

    // Only notify if changed to avoid unnecessary rebuilds, but ValueNotifier handles equality check usually.
    _isProController.value = isPro;

    // 3. Update Cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cacheKeyIsPro, isPro);
      debugPrint('💾 Pro Status Cached: $isPro');
    } catch (e) {
      debugPrint('⚠️ Failed to cache pro status: $e');
    }
  }

  /// Check if user has active premium entitlement
  Future<bool> isUserPremium() async {
    if (!_isInitialized) return false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // Ensure we push this latest info to stream as well
      if (!_customerInfoController.isClosed) {
        _customerInfoController.add(customerInfo);
      }
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ Error checking premium status: $e');
      return false;
    }
  }

  /// Get the Product Identifier of the currently active entitlement (if any)
  /// Returns null if not active.
  Future<String?> getActivePlanId() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[_entitlementID];
      if (entitlement?.isActive == true) {
        return entitlement?.productIdentifier;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if a set of product IDs are eligible for trial/intro offers
  /// Returns a map of ProductId -> IntroEligibilityStatus
  Future<Map<String, IntroEligibility>> checkTrialEligibility(
      List<String> productIdentifiers) async {
    if (!_isInitialized) return {};
    try {
      final eligibility =
          await Purchases.checkTrialOrIntroductoryPriceEligibility(
              productIdentifiers);
      return eligibility;
    } on PlatformException catch (e) {
      debugPrint('❌ Error checking trial eligibility: ${e.message}');
      return {};
    }
  }

  /// Check if a package is eligible for trial (Local Check for UI existence only)
  /// Use [checkTrialEligibility] for strict network check.
  bool hasIntroPrice(Package package) {
    return package.storeProduct.introductoryPrice != null;
  }

  /// Fetch current offerings
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized yet');
      return null;
    }
    try {
      Offerings offerings = await Purchases.getOfferings();
      debugPrint('📦 Offerings fetched: ${offerings.all.keys.toList()}');
      return offerings;
    } on PlatformException catch (e) {
      debugPrint('❌ Error fetching offerings: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error fetching offerings: $e');
    }
    return null;
  }

  /// Purchase a package
  /// Returns: true if purchase successful and entitlement is active, false if cancelled, throws exception on error
  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized yet');
      throw PlatformException(
        code: 'NOT_INITIALIZED',
        message: 'RevenueCat is not initialized',
      );
    }
    try {
      // Use dynamic to handle potential type difference
      dynamic result = await Purchases.purchasePackage(package);
      CustomerInfo customerInfo;

      // Check if result is CustomerInfo or has .customerInfo property (PurchaseResult)
      if (result is CustomerInfo) {
        customerInfo = result;
      } else {
        // Assume it's PurchaseResult or similar wrapper
        try {
          customerInfo = result.customerInfo;
        } catch (_) {
          // Fallback or rethrow if we can't extract it
          debugPrint(
              '❌ Could not extract CustomerInfo from purchase result: $result');
          rethrow;
        }
      }

      final isPro =
          customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;

      if (isPro) {
        debugPrint('✅ Purchase successful - Premium entitlement is active');
        return true;
      } else {
        debugPrint('⚠️ Purchase completed but entitlement not active');
        return false;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('ℹ️ User cancelled purchase');
        return false;
      }
      debugPrint('❌ Purchase error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error during purchase: $e');
      rethrow;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized yet');
      throw PlatformException(
        code: 'NOT_INITIALIZED',
        message: 'RevenueCat is not initialized',
      );
    }
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      final isPro =
          customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
      debugPrint('♻️ Restore complete. isPro: $isPro');
      return isPro;
    } on PlatformException catch (e) {
      debugPrint('❌ Error restoring purchases: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error restoring purchases: $e');
      rethrow;
    }
  }

  /// Get current plan name based on active subscription
  Future<String> getCurrentPlanName() async {
    if (!_isInitialized) {
      return AppStrings.planBasic;
    }
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[_entitlementID];

      if (entitlement?.isActive == true) {
        final productId = entitlement!.productIdentifier.toLowerCase();
        if (productId.contains('monthly') || productId.contains('شهري')) {
          return AppStrings.planPremiumMonthly;
        } else if (productId.contains('six') ||
            productId.contains('6') ||
            productId.contains('ممتد')) {
          return AppStrings.planPremiumExtended;
        } else if (productId.contains('annual') ||
            productId.contains('yearly') ||
            productId.contains('سنوي')) {
          return AppStrings.planPremiumYearly;
        }
        return AppStrings.planPremium;
      }
      return AppStrings.planBasic;
    } catch (e) {
      debugPrint('❌ Error getting current plan name: $e');
      return AppStrings.planBasic;
    }
  }

  bool get isInitialized => _isInitialized;

  // --- Usage Limits Logic ---

  /// Check if user can add a manual quote (Limit: 15 for free users)
  Future<bool> canAddManualQuote() async {
    final isPro = _isProController.value;
    if (isPro) return true; // Unlimited for Pro

    try {
      // We need to inject QuoteRepository here or use GetIt
      // Using GetIt service locator pattern as SubscriptionManager is a singleton
      // and we want to avoid circular dependency if possible.
      // Ideally, we should inject repository, but for simplicity in this existin singleton:
      final countResult = await _getQuoteCount('manual');
      return countResult < 15;
    } catch (e) {
      debugPrint('⚠️ Error checking manual quote limit: $e');
      return true; // As fail-safe, allow adding if check fails
    }
  }

  /// Check if user can scan an image (Limit: 15 for free users)
  Future<bool> canScanImage() async {
    final isPro = _isProController.value;
    if (isPro) return true;

    try {
      final countResult = await _getQuoteCount('scan');
      return countResult < 15;
    } catch (e) {
      debugPrint('⚠️ Error checking scan limit: $e');
      return true;
    }
  }

  // Helper to get count from repository via GetIt (Service Locator)
  // We accept that we are accessing sl directly here.
  // Helper to get count from repository via GetIt (Service Locator)
  Future<int> _getQuoteCount(String source) async {
    try {
      final repo = sl<QuoteRepository>();
      final result = await repo.getQuotesCount(source: source);
      return result.fold(
        (failure) {
          debugPrint('⚠️ Failed to get quote count: ${failure.message}');
          return 0; // Fallback
        },
        (count) => count,
      );
    } catch (e) {
      debugPrint('⚠️ Error getting quote count: $e');
      return 0;
    }
  }
}
