import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static Future<void> configureRevenueCat(String apiKey) async {
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      print("RevenueCat configured successfully.");
    } catch (e) {
      print("Error configuring RevenueCat: $e");
    }
  }

  static Future<Offerings?> fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      print("Error fetching offerings: $e");
      return null;
    }
  }

  static Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      PurchaseResult result = await Purchases.purchasePackage(package);
      print("Package purchased successfully");
      return result.customerInfo;
    } catch (e) {
      print("Error purchasing package: $e");
      return null;
    }
  }

  static Future<bool> isUserSubscribed() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      bool isSubscribed = customerInfo.entitlements.active.containsKey('pro');
      print(" User subscription status: $isSubscribed");
      return isSubscribed;
    } catch (e) {
      print("Error checking subscription status: $e");
      return false;
    }
  }
}
