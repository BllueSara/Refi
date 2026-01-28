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
      if (e.code == 'MissingPluginException' || e.message?.contains('No implementation found') == true) {
        debugPrint('');
        debugPrint('⚠️⚠️⚠️ IMPORTANT: RevenueCat plugin is not linked! ⚠️⚠️⚠️');
        debugPrint('   This usually happens when:');
        debugPrint('   1. You used Hot Reload instead of Full Restart');
        debugPrint('   2. The app was not fully rebuilt after adding the plugin');
        debugPrint('   SOLUTION: Stop the app completely and run: flutter run');
        debugPrint('   Or use: flutter clean && flutter pub get && flutter run');
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
        debugPrint('   2. The app was not fully rebuilt after adding the plugin');
        debugPrint('   SOLUTION: Stop the app completely and run: flutter run');
        debugPrint('   Or use: flutter clean && flutter pub get && flutter run');
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
  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) {
      debugPrint('⚠️ RevenueCat not initialized yet');
      throw PlatformException(
        code: 'NOT_INITIALIZED',
        message: 'RevenueCat is not initialized',
      );
    }
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
      return customerInfo.entitlements.all[_entitlementID]?.isActive ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ Error restoring purchases: ${e.message}');
      throw e;
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

  /// Check if RevenueCat is initialized
  bool get isInitialized => _isInitialized;
}
