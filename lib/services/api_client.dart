import 'package:dio/dio.dart';
import 'package:fis_app_flutter/config/api_config.dart';
import 'package:fis_app_flutter/config/auth_config.dart';
import 'package:fis_app_flutter/services/auth_navigation.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // 1) İstek/yanıt logları (şifre gibi alanları maskele)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final maskedBody = _maskSensitive(options.data);

          if (kDebugMode) {
            print(
                '--> ${options.method} ${options.uri}\nHeaders: ${options.headers}\nBody: $maskedBody');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('<-- ${response.statusCode} ${response.requestOptions.uri}');
          }
          handler.next(response);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            print(
                'xxx ${e.response?.statusCode ?? ''} ${e.requestOptions.uri} ${e.message}');
          }
          handler.next(e);
        },
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
        onError: (e, handler) async {
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
    await _writeValue(AuthConfig.tokenKey, token);
    if (expUnixSeconds != null) {
      await _writeValue(AuthConfig.tokenExpKey, expUnixSeconds.toString());
    }
  }

  /// Get token if still valid
  Future<String?> getValidToken() async {
    _tokenCache ??= await _readValue(AuthConfig.tokenKey);

    final expStr = await _readValue(AuthConfig.tokenExpKey);
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
    await _deleteValue(AuthConfig.tokenKey);
    await _deleteValue(AuthConfig.tokenExpKey);
  }

  bool get _useSharedPrefsStorage =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> _writeValue(String key, String value) async {
    if (_useSharedPrefsStorage) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }

    await _storage.write(key: key, value: value);
  }

  Future<String?> _readValue(String key) async {
    if (_useSharedPrefsStorage) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }

    return _storage.read(key: key);
  }

  Future<void> _deleteValue(String key) async {
    if (_useSharedPrefsStorage) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }

    await _storage.delete(key: key);
  }

  dynamic _maskSensitive(dynamic data) {
    if (data is Map) {
      final copy = <String, dynamic>{};
      data.forEach((key, value) {
        if (key is String) {
          if (key.toLowerCase().contains('password')) {
            copy[key] = '***';
          } else {
            copy[key] = _maskSensitive(value);
          }
        } else {
          copy[key.toString()] = _maskSensitive(value);
        }
      });
      return copy;
    }

    if (data is List) {
      return data.map(_maskSensitive).toList();
    }

    return data;
  }
}
