import 'dart:async';
import 'dart:convert';

import 'package:fis_app_flutter/app/providers/user_plan_provider.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  PurchaseService({
    required this.userPlanProvider,
  });
  final InAppPurchase _iap = InAppPurchase.instance;
  final _api = ApiClient();
  final UserPlanProvider userPlanProvider;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('In-app purchases are not available on this device.');
    }

    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _sub?.cancel(),
      onError: (Object? e) => debugPrint('purchaseStream error: $e'),
    );
  }

  void dispose() {
    unawaited(_sub?.cancel());
  }

  Future<List<ProductDetails>> loadProducts(Set<String> productIds) async {
    final res = await _iap.queryProductDetails(productIds);
    if (res.error != null) {
      throw Exception('Product query failed: ${res.error}');
    }
    if (res.productDetails.isEmpty) {
      throw Exception(
        'No products returned. Check productIds and App Store Connect status.',
      );
    }
    return res.productDetails;
  }

  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);

    // If subscription: buyNonConsumable is OK for StoreKit2 subscriptions in plugin,
    // plugin handles correct underlying behavior.
    // Some teams use buyConsumable only for consumables.
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      debugPrint(
        'Purchase update: ${p.status} ${p.productID} purchaseID=${p.purchaseID}',
      );

      switch (p.status) {
        case PurchaseStatus.pending:
          // show loading indicator
          return;

        case PurchaseStatus.error:
          debugPrint('Purchase error: ${p.error}');
          // show UI error
          return;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliver(p);
          return;

        case PurchaseStatus.canceled:
          // handle cancel
          return;
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails p) async {
    // 🔑 transactionId for backend:
    final transactionId = p.purchaseID;

    if (transactionId == null || transactionId.isEmpty) {
      // If this happens on iOS, we need to adjust backend to accept signed JWS/receipt.
      debugPrint('❌ purchaseID is null; cannot verify via transactionId. '
          'Need backend support for serverVerificationData or StoreKit2 JWS.');
      // Still complete purchase so Apple doesn't keep it pending
      await _completeIfNeeded(p);
      return;
    }

    try {
      // 1) call backend immediately
      final json = await verifyApplePurchase(
        productId: p.productID,
        transactionId: transactionId,
      );

      final entitlement = json['entitlement'] as Map<String, dynamic>;
      userPlanProvider.setFromEntitlementJson(entitlement);

      debugPrint('✅ Verified and entitlement updated: $entitlement');
    } on Exception catch (e) {
      debugPrint('❌ verify failed: $e');
      // In UI: show "Verification failed, contact support"
      // Important: do NOT grant quota locally if backend verify fails
    } finally {
      // 2) finalize with Apple so it won't re-deliver
      await _completeIfNeeded(p);
    }
  }

  Future<void> _completeIfNeeded(PurchaseDetails p) async {
    if (p.pendingCompletePurchase) {
      await _iap.completePurchase(p);
    }
  }

  Future<Map<String, dynamic>> verifyApplePurchase({
    required String productId,
    required String transactionId,
  }) async {
    final payload = {
      'productId': productId,
      'transactionId': transactionId,
    };

    final res = await _api.dio
        .post<Map<String, dynamic>>('/api/iap/apple/verify', data: payload);

    if (res.statusCode != null &&
        res.statusCode! >= 200 &&
        res.statusCode! < 300) {
      return res.data is Map<String, dynamic>
          ? res.data!
          : jsonDecode(res.data.toString()) as Map<String, dynamic>;
    }

    throw Exception('Verify failed: ${res.statusCode} ${res.data}');
  }
}
