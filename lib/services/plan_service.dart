import '../models/plan_option.dart';
import 'api_client.dart';

class PlanService {
  PlanService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;
  static const String _endpoint = '/api/plans';
  static const String _userPlanEndpoint = '/api/user-plans/user';

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

  Future<String?> fetchUserPlanKey() async {
    final response = await _api.dio.get(_userPlanEndpoint);
    if (response.statusCode == 200) {
      return _extractPlanKey(response.data);
    }
    throw Exception('Kullanıcı planı alınamadı (${response.statusCode})');
  }

  Future<void> updateUserPlan(String planKey) async {
    final payload = {'planKey': planKey};
    final response =
        await _api.dio.post(_userPlanEndpoint, data: payload);
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

  String? _extractPlanKey(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      return data['planKey']?.toString() ??
          data['plan']?.toString() ??
          _extractPlanKey(data['data']);
    }
    if (data is List) {
      for (final item in data) {
        final key = _extractPlanKey(item);
        if (key != null && key.isNotEmpty) return key;
      }
    }
    return null;
  }
}
