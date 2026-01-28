import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionManager {
  static const String _apiKey = 'test_moYGPLYjVYlCVVyiATwqWcfsGKb';
  static const String _entitlementID = 'premium_access';

  // Private constructor
  SubscriptionManager._();

  // Singleton instance
  static final SubscriptionManager instance = SubscriptionManager._();

  bool _isInitialized = false;

  /// Initialize RevenueCat
  Future<void> init() async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKey);
    } else {
      // For web or other platforms if needed
      configuration = PurchasesConfiguration(_apiKey);
    }

    try {
      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('✅ RevenueCat Configured');
    } catch (e) {
      debugPrint('❌ Failed to configure RevenueCat: $e');
    }
  }

  /// Check if user has active premium entitlement
  Future<bool> isUserPremium() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ Error checking premium status: ${e.message}');
      return false;
    }
  }

  /// Fetch current offerings
  Future<Offerings?> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings;
      } else {
        debugPrint('⚠️ No current offerings found');
      }
    } on PlatformException catch (e) {
      debugPrint('❌ Error fetching offerings: ${e.message}');
    }
    return null;
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
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

      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('❌ Purchase error: ${e.message}');
        throw e; // Rethrow to handle in UI
      } else {
        debugPrint('ℹ️ User cancelled purchase');
        return false;
      }
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ Error restoring purchases: ${e.message}');
      throw e;
    }
  }
}
