import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/feature/model/home.dart';

class HomeService {
  final _api = ApiClient();

  Future<ModelHome> fetchSummary() async {
    final response = await _api.dio.get<dynamic>('/api/home/summary');
    final data = response.data;
    if (data is List && data.isNotEmpty) {
      return ModelHome.fromResponse(data[0]);
    } else if (data is Map<String, dynamic>) {
      return ModelHome.fromResponse(data);
    }
    throw Exception('Failed to load home summary');
  }
}
