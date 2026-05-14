import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/model/user_profile.dart';

class UserService {
  UserService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<UserProfile> fetchCurrentUser() async {
    try {
      final response = await _api.dio.get<dynamic>('/api/users');

      if (response.statusCode == 200) {
        final map = _extractUserMap(response.data);
        if (map != null) {
          return UserProfile.fromJson(map);
        }
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }
      throw Exception(
        'Kullanıcı bilgisi alınamadı (Kod: ${response.statusCode})',
      );
    } on DioException catch (e) {
      throw Exception(
        'UserService: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      throw Exception('Geçerli bir e-posta adresi bulunamadı');
    }

    final response = await _api.dio.post<dynamic>(
      '/api/auth/resend-email-verification',
      data: {'email': normalizedEmail},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Doğrulama e-postası gönderilemedi');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await _api.dio.delete<dynamic>('/api/users');

      if (response.statusCode != 200 &&
          response.statusCode != 202 &&
          response.statusCode != 204) {
        throw Exception('Hesap silinemedi');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Hesap silinemedi');
    }
  }

  Map<String, dynamic>? _extractUserMap(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['user'] is Map) {
        return Map<String, dynamic>.from(map['user'] as Map);
      }
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }

      if (map.containsKey('_id') ||
          map.containsKey('id') ||
          map.containsKey('email')) {
        return map;
      }
    }

    if (data is List && data.isNotEmpty) {
      return _extractUserMap(data.first);
    }

    return null;
  }
}
