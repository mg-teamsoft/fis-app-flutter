import 'package:flutter/material.dart';

class AuthNavigation {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Redirects to /login (clears stack) and shows an optional SnackBar message.
  static void redirectToLogin({String? message}) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    if (message != null && message.isNotEmpty) {
      final ctx = nav.context;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    nav.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}