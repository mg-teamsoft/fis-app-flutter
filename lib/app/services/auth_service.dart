import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';

class AuthResult {
  AuthResult({required this.success, this.message, this.userId, this.userName});
  final bool success;
  final String? message;
  final String? userId;
  final String? userName;
}

class AuthService {
  final _api = ApiClient();

  /// Calls POST /auth/login with { userName, password }
  /// Expects { status, token, exp, user: { userId, userName } }
  Future<AuthResult> login(String userName, String password) async {
    try {
      final res = await _api.dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {
          'userName': userName.trim(),
          'password': password,
        },
      );

      final rawData = res.data;
      if (rawData is! Map<String, dynamic>) {
        return AuthResult(
          success: false,
          message: 'Unexpected login response format',
        );
      }

      final data = rawData;
      final payload = _extractPayload(data);
      final token = _readString(
        payload,
        const ['token', 'accessToken', 'authToken', 'jwt'],
      );
      final exp = _readInt(payload, const ['exp', 'expiresAt', 'expiresIn']);
      final user = _extractUser(data, payload);
      final uid = _readString(user, const ['userId', 'id']);
      final uname = _readString(user, const ['userName', 'username', 'name']);
      final message = _readString(data, const ['message', 'error', 'detail']) ??
          _readString(payload, const ['message', 'error', 'detail']);
      final success = _isLoginSuccessful(data, payload, token);

      if (!success) {
        return AuthResult(success: false, message: message ?? 'Login failed');
      }

      if (token == null || token.isEmpty) {
        return AuthResult(
          success: false,
          message: message ?? 'Token missing in response',
        );
      }

      await _api.saveToken(token, expUnixSeconds: exp);

      return AuthResult(
        success: true,
        message: message,
        userId: uid,
        userName: uname,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      final msg = responseData is Map<String, dynamic>
          ? (responseData['message']?.toString() ?? e.message)
          : e.message;
      return AuthResult(success: false, message: msg ?? 'Login failed');
    } on Exception catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  /// Register a new user
  /// POST /auth/register
  /// Body: { userId? (server can generate), userName, password, email }
  /// Response: { status, message, data?: { userId, userName } }
  Future<AuthResult> register({
    required String userName,
    required String password,
    required String email,
    String? planKey,
  }) async {
    try {
      final payload = {
        'userName': userName.trim(),
        'password': password,
        'email': email.trim(),
        // userId is optional — backend generates UUID if empty
      };

      if (planKey != null && planKey.trim().isNotEmpty) {
        payload['planKey'] = planKey.trim();
      }

      final res = await _api.dio
          .post<Map<String, dynamic>>('/api/auth/register', data: payload);

      final data = res.data!;
      final ok = data['status'] == 'success';
      final msg = data['message']?.toString();

      String? uid;
      String? uname;
      final d = data['data'];
      if (d is Map) {
        uid = d['userId']?.toString();
        uname = d['userName']?.toString();
      }

      return AuthResult(
        success: ok,
        message: msg,
        userId: uid,
        userName: uname,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = responseData is Map<String, dynamic>
          ? (responseData['message']?.toString() ?? e.message)
          : e.message;
      return AuthResult(success: false, message: msg ?? 'Register failed');
    } on Exception catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  /// Logout a user
  /// POST /auth/revoke
  /// clears stored token
  /// Response: { status, message }
  Future<void> logout() async {
    await _api.dio.post<Map<String, dynamic>>('/api/auth/revoke');
    await _api.clearToken();
  }

  Future<Object> requestPasswordReset(String email) async {
    try {
      final res = await _api.dio.post<Map<String, dynamic>>(
        '/api/auth/request-password-reset',
        data: {'email': email},
      );
      final data = res.data;
      if (data is Map && data!['message'] != null) {
        return data['message'].toString();
      }
      if (data is String && data!.isNotEmpty) {
        return data;
      }
      return 'Şifre sıfırlama isteği gönderildi';
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = responseData is Map<String, dynamic>
          ? (responseData['message']?.toString() ?? e.message)
          : e.message;
      throw Exception(msg ?? 'Şifre sıfırlama isteği başarısız');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Reset password with token + new password
  Future<AuthResult> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post<Map<String, dynamic>>(
        '/api/auth/reset-password',
        data: {'token': token, 'password': password},
      );
      final data = res.data;
      final ok = data!['status'] == 'success';
      final msg = data['message']?.toString();
      return AuthResult(success: ok, message: msg);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = responseData is Map<String, dynamic>
          ? (responseData['message']?.toString() ?? e.message)
          : e.message;
      return AuthResult(
        success: false,
        message: msg ?? 'Reset password failed',
      );
    } on Exception catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> data) {
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    return data;
  }

  Map<String, dynamic> _extractUser(
    Map<String, dynamic> data,
    Map<String, dynamic> payload,
  ) {
    final user = data['user'] ?? payload['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }
    return payload;
  }

  bool _isLoginSuccessful(
    Map<String, dynamic> data,
    Map<String, dynamic> payload,
    String? token,
  ) {
    final status = (_readString(data, const ['status']) ??
            _readString(payload, const ['status']) ??
            '')
        .toLowerCase();
    final ok = data['ok'] == true || payload['ok'] == true;

    if (status == 'success' || status == 'ok' || ok) {
      return true;
    }

    return token != null && token.isNotEmpty;
  }

  String? _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  int? _readInt(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
