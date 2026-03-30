import 'dart:async';
import 'package:fis_app_flutter/app/services/purchase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'user_plan_provider.dart';

class PurchaseProvider extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;

  final PurchaseService purchaseService;
  final UserPlanProvider userPlanProvider;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool isAvailable = false;
  bool isLoading = false;
  String? error;

  List<ProductDetails> products = [];

  PurchaseProvider(
    this.purchaseService,
    this.userPlanProvider,
  ) {
    _ensurePurchaseStream();
  }

  Future<void> init(Set<String> productIds) async {
    try {
      debugPrint('IAP init called. productIds=$productIds');
      isLoading = true;
      error = null;
      notifyListeners();

      isAvailable = await _iap.isAvailable();
      debugPrint('IAP isAvailable: $isAvailable');
      if (!isAvailable) {
        throw Exception("In-app purchases are not available on this device.");
      }

      _ensurePurchaseStream();

      // Load product details
      final resp = await _iap.queryProductDetails(productIds);
      debugPrint(
        'IAP query response: error=${resp.error}, '
        'notFound=${resp.notFoundIDs}, '
        'products=${resp.productDetails.map((p) => p.id).toList()}',
      );

      if (resp.error != null) {
        throw Exception("Product query failed: ${resp.error}");
      }

      if (resp.productDetails.isEmpty) {
        throw Exception(
          "No products returned. Check productIds and App Store Connect status.",
        );
      }

      products = resp.productDetails;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buy(ProductDetails product) async {
    try {
      debugPrint('IAP buy called: ${product.id}');
      isLoading = true;
      error = null;
      notifyListeners();

      _ensurePurchaseStream();
      final purchaseParam = PurchaseParam(
        productDetails: product,
        // Helps correlate purchases to users on some platforms
        applicationUserName: null,
      );

      final isConsumable = product.id == 'com.myfisapp.consumable.100scans';

      if (isConsumable) {
        // Consumable packs should use buyConsumable
        await _iap.buyConsumable(
          purchaseParam: purchaseParam,
          autoConsume: true,
        );
      } else {
        // Subscriptions / non-consumables
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }

      // Do NOT set isLoading=false here. We wait for purchaseStream updates.
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void _ensurePurchaseStream() {
    if (_sub != null) return;
    debugPrint('IAP subscribe to purchaseStream');
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () async {
        debugPrint('IAP purchaseStream done');
        await _sub?.cancel();
        _sub = null;
      },
      onError: (e) async {
        error = "purchaseStream error: $e";
        debugPrint(error);
        isLoading = false;
        notifyListeners();
        await _sub?.cancel();
        _sub = null;
      },
    );
  }

  Future<void> restorePurchases() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _iap.restorePurchases();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdates(
      List<PurchaseDetails> purchaseDetailsList) async {
    debugPrint(
      'On IAP purchase updates: count=${purchaseDetailsList.length}',
    );
    for (final p in purchaseDetailsList) {
      debugPrint(
        "Purchase update: status=${p.status} product=${p.productID} purchaseID=${p.purchaseID}",
      );

      switch (p.status) {
        case PurchaseStatus.pending:
          isLoading = true;
          notifyListeners();
          break;

        case PurchaseStatus.error:
          error = "Purchase failed: ${p.error}";
          await _completeIfNeeded(p);
          isLoading = false;
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isLoading = true;
          notifyListeners();
          await _verifyAndDeliver(p);
          isLoading = false;
          notifyListeners();
          break;

        case PurchaseStatus.canceled:
          error = "Purchase canceled.";
          await _completeIfNeeded(p);
          isLoading = false;
          notifyListeners();
          break;
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails p) async {
    debugPrint(
      'IAP verify start: status=${p.status} product=${p.productID} purchaseID=${p.purchaseID}',
    );
    final transactionId = p.purchaseID;

    if (transactionId == null || transactionId.isEmpty) {
      // If this happens, backend verify-by-transactionId cannot work.
      // You’ll need to support receipt/JWS verification instead.
      error = "Purchase completed but transactionId is missing. "
          "Please contact support (dev: purchaseID is null).";

      await _completeIfNeeded(p);
      return;
    }

    try {
      error = null;

      final json = await purchaseService.verifyApplePurchase(
        productId: p.productID,
        transactionId: transactionId,
      );
      debugPrint('IAP verify response: $json');

      // expected backend response:
      // { status: "ok", entitlement: { planKey, quota, ... } }
      final entitlement = (json["entitlement"] as Map<String, dynamic>?);
      if (entitlement == null) {
        throw Exception("Backend response missing 'entitlement'");
      }

      userPlanProvider.setFromEntitlementJson(entitlement);
    } catch (e) {
      error = "Verification failed: $e";
    } finally {
      await _completeIfNeeded(p);
    }
  }

  Future<void> _completeIfNeeded(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(p);
    } catch (e) {
      debugPrint('IAP completePurchase failed: $e');
      // Keep non-fatal; user already purchased/failed on Apple side.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
