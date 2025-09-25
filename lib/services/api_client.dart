import 'package:dio/dio.dart';
import 'package:fis_app_flutter/services/auth_navigation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../config/auth_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeoutMs),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 1) İstek/yanıt logları
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _tokenCache ?? await getValidToken();
          if (token != null && token.isNotEmpty) {
            options.headers[AuthConfig.authorizationHeader] =
                '${AuthConfig.bearerPrefix} $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Token expired or invalid
            await clearToken();

            // Notify listeners (UI) to redirect to login
            AuthNavigation.redirectToLogin(
              message: AuthConfig.sessionExpiredMessage,
            );

            // Optionally swallow the error if you don’t want to show a dialog
          }
          handler.next(e);
        },
      ),
    );
  }

  late final Dio _dio;
  Dio get dio => _dio;

  // ---- Token storage
  final _storage = const FlutterSecureStorage();
  String? _tokenCache;
  int? _expCache;

  /// Save token and its expiry (in seconds since epoch)
  Future<void> saveToken(String token, {int? expUnixSeconds}) async {
    _tokenCache = token;
    _expCache = expUnixSeconds;
    await _storage.write(key: AuthConfig.tokenKey, value: token);
    if (expUnixSeconds != null) {
      await _storage.write(
        key: AuthConfig.tokenExpKey,
        value: expUnixSeconds.toString(),
      );
    }
  }

  /// Get token if still valid
  Future<String?> getValidToken() async {
    _tokenCache ??= await _storage.read(key: AuthConfig.tokenKey);

    final expStr = await _storage.read(key: AuthConfig.tokenExpKey);
    if (expStr != null) _expCache = int.tryParse(expStr);

    if (_expCache != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final effectiveExp = _expCache! - AuthConfig.tokenSkewSeconds;
      if (effectiveExp <= now) {
        await clearToken();
        return null;
      }
    }
    return _tokenCache;
  }

  Future<void> clearToken() async {
    _tokenCache = null;
    _expCache = null;
    await _storage.delete(key: AuthConfig.tokenKey);
    await _storage.delete(key: AuthConfig.tokenExpKey);
  }
}
