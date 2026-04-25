import 'package:fis_app_flutter/app/import/page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class RouterGeneral {
  final String? _initialRoute = kIsWeb ? null : '/login';
  // GET function
  Map<String, Widget Function(BuildContext)> get routes => {
    '/': (_) => const PageLogin(),
    '/login': (_) => const PageLogin(),
    '/register': (_) => const PageRegister(),
    '/forgotPassword': (_) => const PageForgotPassword(),
    '/contacts/invites/accept': (_) => const PageContactInviteAccept(),
    '/home': (_) => const MainLayout(), // Home Page is default value
    '/connections': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      print('DEBUG: /connections args = $args');
      return MainLayout(
        initialRoute: '/connections',
        initialArguments: args,
      );
    },
    '/excelFiles': (_) => const MainLayout(initialRoute: '/excelFiles'),
    '/about': (_) => const MainLayout(initialRoute: '/about'),
    '/settings': (_) => const MainLayout(initialRoute: '/settings'),
    '/accountSettings': (_) =>
        const MainLayout(initialRoute: '/accountSettings'),
    '/receipt': (_) => const MainLayout(initialRoute: '/receipt'),
    '/notification': (_) => const MainLayout(initialRoute: '/notification'),
    '/gallery': (_) => const MainLayout(initialRoute: '/gallery'),
    '/receipt/process': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return MainLayout(
        initialRoute: '/receipt/process',
        initialArguments: args,
      );
    },
    '/receipt/results': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return MainLayout(
        initialRoute: '/receipt/results',
        initialArguments: args,
      );
    },
    '/receipt/manuel': (_) => const MainLayout(initialRoute: '/receipt/manuel'),
    '/resetPassword': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['init'] == true) {
        return const MainLayout(initialRoute: '/resetPassword');
      }
      return const PageResetPassword();
    },
  };

  String? get initialRoute => _initialRoute;
}
