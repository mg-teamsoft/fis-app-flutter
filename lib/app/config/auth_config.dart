import 'package:fis_app_flutter/app/config/app_config.dart';

/// Central place for auth-related constants.
/// Values are namespaced by ENV (dev/staging/prod) so parallel installs don't clash.
class AuthConfig {
  // Secure storage keys (namespaced by ENV)
  static String get tokenKey => '${AppConfig.env}_auth_token';
  static String get tokenExpKey => '${AppConfig.env}_auth_token_exp';

  /// Optional clock skew to treat tokens as expired slightly before 'exp'
  static const tokenSkewSeconds = 15;

  /// Default message shown when a 401 triggers auto-logout
  static const sessionExpiredMessage =
      'Oturum süresi doldu. Lütfen tekrar giriş yapın.';

  /// Header name for bearer, if you ever need to change it centrally
  static const authorizationHeader = 'Authorization';

  /// Prefix for bearer tokens
  static const bearerPrefix = 'Bearer';
}
