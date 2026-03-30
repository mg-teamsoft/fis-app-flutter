import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/feature/model/home.dart';

class HomeService {
  final _api = ApiClient();

  Future<ModelHome> fetchSummary() async {
    final response = await _api.dio.get<dynamic>('/api/home/summary');
    if (response.statusCode == 200) {
      return ModelHome.fromResponse(response.data);
    }
    throw Exception('Failed to load home summary');
  }
}
