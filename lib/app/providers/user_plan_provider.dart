import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:flutter/foundation.dart';

class UserPlan {
  const UserPlan({
    required this.planKey,
    required this.remainingQuota,
    this.endDate,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) {
    int readInt(String key) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    // Backend uses "quota" as remaining amount; keep remainingQuota in app model.
    final remaining = readInt('remainingQuota') != 0
        ? readInt('remainingQuota')
        : readInt('quota');

    final rawPlanKey = (json['planKey'] ?? 'FREE').toString().trim();
    final normalizedPlanKey =
        rawPlanKey.isEmpty ? 'FREE' : rawPlanKey.toUpperCase();

    final endDateRaw = json['endDate'] ?? json['expiresAt'];

    return UserPlan(
      planKey: normalizedPlanKey,
      remainingQuota: remaining,
      endDate:
          endDateRaw != null ? DateTime.tryParse(endDateRaw.toString()) : null,
    );
  }
  final String planKey; // FREE, MONTHLY, YEARLY
  final int remainingQuota;
  final DateTime? endDate;

  bool get isPaid =>
      planKey.startsWith('MONTHLY') || planKey.startsWith('YEARLY');
  bool get canScan => remainingQuota > 0;
}

class UserPlanProvider extends ChangeNotifier {
  UserPlanProvider(this._api);
  final ApiClient _api;

  UserPlan _plan = const UserPlan(planKey: 'FREE', remainingQuota: 0);

  bool isLoading = false;
  String? error;

  UserPlan get plan => _plan;

  // Convenience getters
  String get planKey => _plan.planKey;
  int get remainingQuota => _plan.remainingQuota;
  DateTime? get endDate => _plan.endDate;
  bool get isPaid => _plan.isPaid;
  bool get canScan => _plan.canScan;

  void setFromPlanJson(Map<String, dynamic> planJson) {
    _plan = UserPlan.fromJson(planJson);
    error = null;
    notifyListeners();
  }

  /// Backend verify returns { status:"ok", entitlement:{...} }
  void setFromEntitlementJson(Map<String, dynamic> entitlementJson) {
    _plan = UserPlan.fromJson(entitlementJson);
    error = null;
    notifyListeners();
  }

  void reset() {
    _plan = const UserPlan(planKey: 'FREE', remainingQuota: 0);
    error = null;
    isLoading = false;
    notifyListeners();
  }

  /// Calls GET /user-plans/me
  Future<void> loadMyPlan() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final res =
          await _api.dio.get<dynamic>('/api/user-plans/user');

      final data = res.data;

      Map<String, dynamic>? planJson;
      if (data is List && data.isNotEmpty) {
        final active = data.firstWhere(
            (p) => p is Map && p['isActive'] == true,
            orElse: () => data.first);
        if (active is Map) {
          planJson = Map<String, dynamic>.from(active);
        }
      } else if (data is Map) {
        if (data.containsKey('plan') && data['plan'] is Map) {
          planJson = Map<String, dynamic>.from(data['plan'] as Map);
        } else {
          planJson = Map<String, dynamic>.from(data);
        }
      }

      if (planJson == null) {
        throw Exception('Unexpected response format');
      }

      _plan = UserPlan.fromJson(planJson);
    } on Exception catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
