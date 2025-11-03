import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthResult {
  final bool success;
  final String? message;
  final String? userId;
  final String? userName;

  AuthResult({required this.success, this.message, this.userId, this.userName});
}

class AuthService {
  final _api = ApiClient();

  /// Calls POST /auth/login with { userName, password }
  /// Expects { status, token, exp, user: { userId, userName } }
  Future<AuthResult> login(String userName, String password) async {
    try {
      final res = await _api.dio.post('/api/auth/login', data: {
        'userName': userName.trim(),
        'password': password,
      });

      final data = res.data as Map<String, dynamic>;
      if (data['status'] != 'success') {
        return AuthResult(success: false, message: data['message']?.toString());
      }

      final token = data['token']?.toString();
      final exp = data['exp'] is int ? data['exp'] as int : null;
      final user = (data['user'] as Map?) ?? {};
      final uid = user['userId']?.toString();
      final uname = user['userName']?.toString();

      if (token == null || token.isEmpty) {
        return AuthResult(success: false, message: 'Token missing in response');
      }

      await _api.saveToken(token, expUnixSeconds: exp);
      return AuthResult(success: true, userId: uid, userName: uname);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? ((e.response!.data['message'] ?? e.message)?.toString())
          : e.message;
      return AuthResult(success: false, message: msg ?? 'Login failed');
    } catch (e) {
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

      final res =
          await _api.dio.post('/api/auth/register', data: payload);

      final data = res.data as Map<String, dynamic>;
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
          success: ok, message: msg, userId: uid, userName: uname);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data['message']?.toString() ?? e.message)
          : e.message;
      return AuthResult(success: false, message: msg ?? 'Register failed');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  /// Logout a user
  /// POST /auth/revoke
  /// clears stored token
  /// Response: { status, message }
  Future<void> logout() async {
    await _api.dio.post('/api/auth/revoke');
    await _api.clearToken();
  }
}
