import 'dart:async';

import 'package:fis_app_flutter/app/providers/user_plan_provider.dart';
import 'package:fis_app_flutter/app/services/purchase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseProvider extends ChangeNotifier {
  PurchaseProvider(
    this.purchaseService,
    this.userPlanProvider,
  ) {
    _ensurePurchaseStream();
  }
  final InAppPurchase _iap = InAppPurchase.instance;

  final PurchaseService purchaseService;
  final UserPlanProvider userPlanProvider;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  Completer<void>? _purchaseCompleter;
  String? _activePurchaseProductId;
  int? _activePurchaseStartedAtMs;

  bool isAvailable = false;
  bool isLoading = false;
  String? error;

  List<ProductDetails> products = [];

  Future<void> init(Set<String> productIds) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        throw Exception('In-app purchases are not available on this device.');
      }

      _ensurePurchaseStream();

      // Load product details
      final resp = await _iap.queryProductDetails(productIds);

      if (resp.error != null) {
        throw Exception('Product query failed: ${resp.error}');
      }

      if (resp.productDetails.isEmpty) {
        throw Exception(
          'No products returned. Check productIds and App Store Connect status.',
        );
      }

      products = resp.productDetails;
    } on Exception catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buy(ProductDetails product) async {
    if (_purchaseCompleter != null) {
      throw Exception('Satın alma işlemi zaten devam ediyor.');
    }

    _purchaseCompleter = Completer<void>();
    _activePurchaseProductId = product.id;
    _activePurchaseStartedAtMs = DateTime.now().millisecondsSinceEpoch;
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      _ensurePurchaseStream();
      final purchaseParam = PurchaseParam(
        productDetails: product,
        // Helps correlate purchases to users on some platforms
        // ignore: avoid_redundant_argument_values
        applicationUserName: null,
      );

      final isConsumable = product.id == 'com.myfisapp.consumable.100scans' ||
          product.id.toLowerCase().contains('consumable');

      if (isConsumable) {
        // Consumable packs should use buyConsumable
        final started = await _iap.buyConsumable(
          purchaseParam: purchaseParam,
        );
        if (!started) {
          throw Exception('Satın alma başlatılamadı.');
        }
      } else {
        // Subscriptions / non-consumables
        final started =
            await _iap.buyNonConsumable(purchaseParam: purchaseParam);
        if (!started) {
          throw Exception('Satın alma başlatılamadı.');
        }
      }

      await _purchaseCompleter!.future;
    } on Exception catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      if (_purchaseCompleter?.isCompleted == false) {
        _purchaseCompleter = null;
        _activePurchaseProductId = null;
        _activePurchaseStartedAtMs = null;
      }
      rethrow;
    } finally {
      if (_purchaseCompleter?.isCompleted ?? false) {
        _purchaseCompleter = null;
        _activePurchaseProductId = null;
        _activePurchaseStartedAtMs = null;
      }
    }
  }

  void _ensurePurchaseStream() {
    if (_sub != null) return;
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () async {
        await _sub?.cancel();
        _sub = null;
      },
      onError: (Object? e) async {
        error = 'purchaseStream error: $e';
        debugPrint(error);
        isLoading = false;
        notifyListeners();
        _completePurchaseFlowError(Exception(error));
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
    } on Exception catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final p in purchaseDetailsList) {
      if (!_isRelevantPurchaseUpdate(p)) {
        debugPrint(
          'Ignoring stale/non-active purchase update: product=${p.productID} '
          'purchaseID=${p.purchaseID}',
        );
        await _completeIgnoredPurchaseUpdate(p);
        continue;
      }

      switch (p.status) {
        case PurchaseStatus.pending:
          isLoading = true;
          notifyListeners();
          continue;

        case PurchaseStatus.error:
          error = 'Purchase failed: ${p.error}';
          await _completeIfNeeded(p);
          isLoading = false;
          notifyListeners();
          _completePurchaseFlowError(Exception(error));
          continue;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isLoading = true;
          notifyListeners();
          await _verifyAndDeliver(p);
          isLoading = false;
          notifyListeners();
          if (error == null) {
            _completePurchaseFlowSuccess();
          } else {
            _completePurchaseFlowError(Exception(error));
          }
          continue;

        case PurchaseStatus.canceled:
          error = 'Purchase canceled.';
          await _completeIfNeeded(p);
          isLoading = false;
          notifyListeners();
          _completePurchaseFlowError(Exception('Satın alma iptal edildi.'));
          continue;
      }
    }
  }

  bool _isRelevantPurchaseUpdate(PurchaseDetails p) {
    final activeProductId = _activePurchaseProductId;
    if (activeProductId == null) return true;
    if (p.productID != activeProductId) return false;

    if (p.status == PurchaseStatus.pending ||
        p.status == PurchaseStatus.error ||
        p.status == PurchaseStatus.canceled) {
      return true;
    }

    final startedAt = _activePurchaseStartedAtMs;
    final transactionAt = _transactionDateMs(p.transactionDate);
    if (startedAt == null || transactionAt == null) return true;

    return transactionAt >=
        startedAt - const Duration(minutes: 5).inMilliseconds;
  }

  int? _transactionDateMs(String? transactionDate) {
    if (transactionDate == null || transactionDate.isEmpty) return null;

    final epochMs = int.tryParse(transactionDate);
    if (epochMs != null) return epochMs;

    final normalized = transactionDate.replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;

    final hasTimezone = RegExp(r'(Z|[+-]\d\d:?\d\d)$').hasMatch(normalized);
    if (hasTimezone) return parsed.millisecondsSinceEpoch;

    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    ).millisecondsSinceEpoch;
  }

  Future<void> _verifyAndDeliver(PurchaseDetails p) async {
    final transactionId = p.purchaseID;

    if (transactionId == null || transactionId.isEmpty) {
      // If this happens, backend verify-by-transactionId cannot work.
      // You’ll need to support receipt/JWS verification instead.
      error = 'Purchase completed but transactionId is missing. '
          'Please contact support (dev: purchaseID is null).';

      await _completeIfNeeded(p);
      return;
    }

    try {
      error = null;

      final json = await purchaseService.verifyApplePurchase(
        productId: p.productID,
        transactionId: transactionId,
      );

      // expected backend response:
      // { status: "ok", entitlement: { planKey, quota, ... } }
      final entitlement = json['entitlement'] as Map<String, dynamic>?;
      if (entitlement == null) {
        throw Exception("Backend response missing 'entitlement'");
      }

      userPlanProvider.setFromEntitlementJson(entitlement);
    } on Exception catch (e) {
      error = 'Verification failed: $e';
    } finally {
      await _completeAfterVerification(p);
    }
  }

  Future<void> _completeIfNeeded(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) {
      return;
    }

    await _completePurchase(p, reason: 'pendingCompletePurchase=true');
  }

  Future<void> _completeIgnoredPurchaseUpdate(PurchaseDetails p) async {
    if (p.status == PurchaseStatus.pending) {
      debugPrint(
        'IAP ignored pending transaction is not completed: ${p.productID} '
        '(purchaseID=${p.purchaseID})',
      );
      return;
    }

    if (p.purchaseID == null || p.purchaseID!.isEmpty) {
      debugPrint(
        'IAP ignored transaction has no purchaseID, cannot complete: '
        '${p.productID} status=${p.status}',
      );
      return;
    }

    await _completePurchase(p, reason: 'ignored stale purchase update');
  }

  Future<void> _completeAfterVerification(PurchaseDetails p) async {
    if (p.pendingCompletePurchase) {
      await _completePurchase(p, reason: 'verified purchase update');
      return;
    }

    if (p.status == PurchaseStatus.restored &&
        p.purchaseID != null &&
        p.purchaseID!.isNotEmpty) {
      await _completePurchase(p, reason: 'verified restored purchase update');
      return;
    }
  }

  Future<void> _completePurchase(
    PurchaseDetails p, {
    required String reason,
  }) async {
    try {
      await _iap.completePurchase(p);
    } on Exception catch (e) {
      debugPrint('IAP completePurchase failed: $e');
      // Keep non-fatal; user already purchased/failed on Apple side.
    }
  }

  void _completePurchaseFlowSuccess() {
    final completer = _purchaseCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  void _completePurchaseFlowError(Object error) {
    final completer = _purchaseCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error);
    }
  }

  @override
  void dispose() {
    _completePurchaseFlowError(Exception('Satın alma işlemi tamamlanamadı.'));
    unawaited(_subCancel());
    super.dispose();
  }

  Future<void> _subCancel() async {
    await _sub?.cancel();
    _sub = null;
  }
}
