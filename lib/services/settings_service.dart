import 'package:dio/dio.dart';

import 'api_client.dart';

class SettingsService {
  final _api = ApiClient();

  Future<Map<String, dynamic>?> fetchRules() async {
    try {
      final res = await _api.dio.get('/api/rule');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return payload;
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception('Ayarlar alınamadı: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmedik hata: $e');
    }
  }

  Future<void> updateRules({
    required String rulesString,
  }) async {
    try {
      await _api.dio.post(
        '/api/rule',
        data: {'rulesString': rulesString},
      );
    } on DioException catch (e) {
      throw Exception('Ayarlar güncellenemedi: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmedik hata: $e');
    }
  }
}
