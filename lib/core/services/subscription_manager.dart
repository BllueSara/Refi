import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants/app_strings.dart';

class SubscriptionManager {
  static const String _apiKey = 'test_moYGPLYjVYlCVVyiATwqWcfsGKb';
  static const String _entitlementID = 'jalees Pro';

  // Private constructor
  SubscriptionManager._();

  // Singleton instance
  static final SubscriptionManager instance = SubscriptionManager._();

  bool _isInitialized = false;

  /// Initialize RevenueCat
  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('✅ RevenueCat already initialized');
      return;
    }

    try {
      debugPrint('🔄 Starting RevenueCat initialization...');
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKey);
        debugPrint('📱 Configuring RevenueCat for Android');
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKey);
        debugPrint('🍎 Configuring RevenueCat for iOS');
      } else {
        configuration = PurchasesConfiguration(_apiKey);
        debugPrint('🌐 Configuring RevenueCat for other platform');
      }

      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('✅ RevenueCat Configured Successfully');
    } on PlatformException catch (e) {
      debugPrint('❌ PlatformException during RevenueCat init: ${e.message}');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Details: ${e.details}');

      // Check if it's a MissingPluginException
      if (e.code == 'MissingPluginException' ||
          e.message?.contains('No implementation found') == true) {
        debugPrint('');
        debugPrint('⚠️⚠️⚠️ IMPORTANT: RevenueCat plugin is not linked! ⚠️⚠️⚠️');
        debugPrint('   This usually happens when:');
        debugPrint('   1. You used Hot Reload instead of Full Restart');
        debugPrint(
            '   2. The app was not fully rebuilt after adding the plugin');
        debugPrint('   SOLUTION: Stop the app completely and run: flutter run');
        debugPrint(
            '   Or use: flutter clean && flutter pub get && flutter run');
        debugPrint('');
      }

      _isInitialized = false;
      rethrow; // Rethrow to let caller know initialization failed
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to configure RevenueCat: $e');
      debugPrint('   Stack trace: $stackTrace');

      // Check if it's a MissingPluginException
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('No implementation found')) {
        debugPrint('');
        debugPrint('⚠️⚠️⚠️ IMPORTANT: RevenueCat plugin is not linked! ⚠️⚠️⚠️');
        debugPrint('   This usually happens when:');
        debugPrint('   1. You used Hot Reload instead of Full Restart');
        debugPrint(
            '   2. The app was not fully rebuilt after adding the plugin');
        debugPrint('   SOLUTION: Stop the app completely and run: flutter run');
        debugPrint(
            '   Or use: flutter clean && flutter pub get && flutter run');
        debugPrint('');
      }

      _isInitialized = false;
      rethrow; // Rethrow to let caller know initialization failed
    }
  }

  /// Check if user has active premium entitlement
  Future<bool> isUserPremium() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized yet');
      return false;
    }
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ Error checking premium status: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error checking premium status: $e');
      return false;
    }
  }

  /// Fetch current offerings
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized yet');
      return null;
    }
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings;
      } else {
        debugPrint('⚠️ No current offerings found');
      }
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
      // Check current status before purchase
      final currentCustomerInfo = await Purchases.getCustomerInfo();
      final wasPremiumBefore =
          currentCustomerInfo.entitlements.all[_entitlementID]?.isActive ??
              false;

      if (wasPremiumBefore) {
        debugPrint('ℹ️ User already has active premium entitlement');
      }

      // Use dynamic to handle potential type mismatch (CustomerInfo vs PurchaseResult)
      // Some versions/extensions might return a wrapper.
      dynamic result = await Purchases.purchasePackage(package);
      CustomerInfo customerInfo;

      if (result is CustomerInfo) {
        customerInfo = result;
      } else {
        // Try to get customerInfo from wrapper if it exists (e.g. PurchaseResult)
        try {
          customerInfo = result.customerInfo;
        } catch (_) {
          // Fallback cast
          customerInfo = result as CustomerInfo;
        }
      }

      final isPremiumAfter =
          customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;

      debugPrint('📊 Purchase result:');
      debugPrint('   Was premium before: $wasPremiumBefore');
      debugPrint('   Is premium after: $isPremiumAfter');
      debugPrint(
          '   Active subscriptions: ${customerInfo.activeSubscriptions.length}');
      debugPrint(
          '   All entitlements: ${customerInfo.entitlements.all.keys.toList()}');

      if (isPremiumAfter) {
        debugPrint('✅ Purchase successful - Premium entitlement is active');
        return true;
      } else {
        // Check if purchase was actually completed but entitlement is not active
        // This might happen if entitlement ID is wrong or subscription expired
        if (customerInfo.activeSubscriptions.isNotEmpty) {
          debugPrint('⚠️ Purchase completed but entitlement not active');
          debugPrint(
              '   Active subscriptions: ${customerInfo.activeSubscriptions}');
          debugPrint('   Looking for entitlement: $_entitlementID');
          debugPrint(
              '   Available entitlements: ${customerInfo.entitlements.all.keys.toList()}');
          // This is an error case - purchase succeeded but entitlement not active
          throw PlatformException(
            code: 'ENTITLEMENT_NOT_ACTIVE',
            message:
                'Purchase completed but premium entitlement is not active. Check entitlement ID configuration.',
          );
        }
        // No active subscriptions and no entitlement - likely cancelled or failed
        debugPrint('⚠️ Purchase did not result in active subscription');
        return false;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('❌ PlatformException during purchase:');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   RevenueCat Error Code: $errorCode');

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('ℹ️ User cancelled purchase');
        return false;
      } else {
        debugPrint('❌ Purchase error: ${e.message}');
        rethrow; // Rethrow to handle in UI
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error during purchase: $e');
      debugPrint('   Stack trace: $stackTrace');
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
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ Error restoring purchases: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error restoring purchases: $e');
      rethrow;
    }
  }

  /// Get customer info for testing/debugging
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized yet');
      return null;
    }
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } on PlatformException catch (e) {
      debugPrint('❌ Error getting customer info: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error getting customer info: $e');
      return null;
    }
  }

  /// Get current plan name based on active subscription
  /// Returns plan name like "جليس شهري", "جليس ممتد", "جليس سنوي", or "جليس" for basic
  Future<String> getCurrentPlanName() async {
    if (!_isInitialized) {
      return AppStrings.planBasic;
    }
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[_entitlementID];

      if (entitlement?.isActive == true) {
        // Get product identifier from entitlement
        final productId = entitlement!.productIdentifier.toLowerCase();

        // Map product IDs to plan names
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
        } else {
          // Check active subscriptions for more info
          if (customerInfo.activeSubscriptions.isNotEmpty) {
            final subscriptionId =
                customerInfo.activeSubscriptions.first.toLowerCase();
            if (subscriptionId.contains('monthly') ||
                subscriptionId.contains('شهري')) {
              return AppStrings.planPremiumMonthly;
            } else if (subscriptionId.contains('six') ||
                subscriptionId.contains('6') ||
                subscriptionId.contains('ممتد')) {
              return AppStrings.planPremiumExtended;
            } else if (subscriptionId.contains('annual') ||
                subscriptionId.contains('yearly') ||
                subscriptionId.contains('سنوي')) {
              return AppStrings.planPremiumYearly;
            }
          }
          // Default to premium if active but can't determine type
          return AppStrings.planPremium;
        }
      }

      return AppStrings.planBasic;
    } catch (e) {
      debugPrint('❌ Error getting current plan name: $e');
      return AppStrings.planBasic;
    }
  }

  /// Check if RevenueCat is initialized
  bool get isInitialized => _isInitialized;
}
