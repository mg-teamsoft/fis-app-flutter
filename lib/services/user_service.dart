import '../models/user_profile.dart';
import 'api_client.dart';

class UserService {
  UserService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<UserProfile> fetchCurrentUser() async {
    final response = await _api.dio.get('/api/users');
    if (response.statusCode == 200) {
      final data = response.data;
      final Map<String, dynamic>? map = _extractUserMap(data);
      if (map != null) {
        return UserProfile.fromJson(map);
      }
      throw Exception('Kullanıcı bilgisi bulunamadı');
    }
    throw Exception('Kullanıcı bilgisi alınamadı (${response.statusCode})');
  }

  Future<void> resendVerificationEmail() async {
    final response = await _api.dio.post('/api/users/resend-verification');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Doğrulama e-postası gönderilemedi');
    }
  }

  Map<String, dynamic>? _extractUserMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['user'] as Map);
      }
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return data;
    }
    if (data is List) {
      for (final item in data) {
        final map = _extractUserMap(item);
        if (map != null) return map;
      }
    }
    return null;
  }
}
