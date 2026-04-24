import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class AuthNavigation {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Redirects to /login (clears stack) and shows an optional SnackBar message.
  static Future<void> redirectToLogin({String? message}) async {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    if (message != null && message.isNotEmpty) {
      final ctx = nav.context;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            ctx,
            message,
            color: ctx.theme.warning,
            weight: FontWeight.w800,
          ),
        ),
      );
    }

    await nav.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
