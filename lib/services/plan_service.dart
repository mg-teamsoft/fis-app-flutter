import '../models/plan_option.dart';
import 'api_client.dart';

class PlanService {
  PlanService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;
  static const String _endpoint = '/api/plans';
  static const String _userPlanEndpoint = '/api/user-plans';

  Future<List<PlanOption>> fetchPlans() async {
    final response = await _api.dio.get(_endpoint);
    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['plans'] is List) {
        list = data['plans'] as List;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else {
        list = const [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(PlanOption.fromJson)
          .where((plan) => plan.id.isNotEmpty && plan.name.isNotEmpty)
          .toList();
    }

    throw Exception('Plan listesi alınamadı (${response.statusCode})');
  }

  Future<UserPlanSummary?> fetchUserPlanKey() async {
    final response = await _api.dio.get('$_userPlanEndpoint/user');
    if (response.statusCode == 200) {
      final plans = _extractUserPlanList(response.data);
      if (plans.isEmpty) return null;
      final activePlan = plans.firstWhere(
        (plan) => plan['isActive'] == true,
        orElse: () => plans.first,
      );
      final id =
          (activePlan['_id'] ?? activePlan['id'])?.toString().trim() ?? '';
      final planKey =
          activePlan['planKey']?.toString().trim() ??
          activePlan['key']?.toString().trim() ??
          '';
      if (id.isEmpty || planKey.isEmpty) return null;
      return UserPlanSummary(
        id: id,
        planKey: planKey,
        isActive: activePlan['isActive'] == true,
      );
    }
    throw Exception('Kullanıcı planı alınamadı (${response.statusCode})');
  }

  Future<void> updateUserPlan({
    required String userPlanId,
    required String planKey,
  }) async {
    final response = await _api.dio.put(
      '$_userPlanEndpoint/$userPlanId',
      data: {'planKey': planKey},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Plan güncellenemedi (${response.statusCode})');
    }
  }

  static List<PlanOption> sortPlansWithFreeFirst(List<PlanOption> plans) {
    if (plans.length <= 1) return plans;
    final sorted = [...plans];
    sorted.sort((a, b) {
      final aIsFree = a.isFreePlan;
      final bIsFree = b.isFreePlan;
      if (aIsFree == bIsFree) return 0;
      return aIsFree ? -1 : 1;
    });
    return sorted;
  }

  List<Map<String, dynamic>> _extractUserPlanList(dynamic data) {
    if (data == null) return const [];

    List<Map<String, dynamic>> normalize(List<dynamic> list) {
      return list
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is List) {
      return normalize(data);
    }

    if (data is Map) {
      if (data['plans'] is List) {
        return normalize(data['plans'] as List);
      }
      if (data['data'] is List) {
        return normalize(data['data'] as List);
      }
      if (data['_id'] != null || data['id'] != null) {
        return [Map<String, dynamic>.from(data)];
      }
    }

    return const [];
  }
}

class UserPlanSummary {
  UserPlanSummary({
    required this.id,
    required this.planKey,
    required this.isActive,
  });

  final String id;
  final String planKey;
  final bool isActive;
}
