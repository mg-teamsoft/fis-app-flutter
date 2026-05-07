import 'package:flutter/material.dart';

class AuthNavigation {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Redirects to /login (clears stack) and shows an optional SnackBar message.
  static Future<void> redirectToLogin({String? message}) async {
    final nav = navigatorKey.currentState;
    if (nav == null || !nav.mounted) return;

    if (message != null && message.isNotEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    await nav.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
