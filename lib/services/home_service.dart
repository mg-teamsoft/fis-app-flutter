import '../models/home_summary.dart';
import 'api_client.dart';

class HomeService {
  final _api = ApiClient();

  Future<HomeSummary> fetchSummary() async {
    final response = await _api.dio.get('/api/home/summary');
    if (response.statusCode == 200) {
      return HomeSummary.fromResponse(response.data);
    }
    throw Exception('Failed to load home summary');
  }
}
