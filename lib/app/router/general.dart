import 'package:fis_app_flutter/app/import/page.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class RouterGeneral {
  final String? _initialRoute = kIsWeb ? null : '/';
  // GET function
  Map<String, Widget Function(BuildContext)> get routes => {
        '/': (_) => const _AuthGate(),
        '/login': (_) => const PageLogin(),
        '/register': (_) => const PageRegister(),
        '/forgotPassword': (_) => const PageForgotPassword(),
        '/contacts/invites/accept': (_) => const PageContactInviteAccept(),
        '/home': (_) => const MainLayout(), // Home Page is default value
        '/connections': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          debugPrint('DEBUG: /connections args = $args');
          return MainLayout(
            initialRoute: '/connections',
            initialArguments: args,
          );
        },
        '/excelFiles': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return MainLayout(
            initialRoute: '/excelFiles',
            initialArguments: args,
          );
        },
        '/about': (_) => const MainLayout(initialRoute: '/about'),
        '/settings': (_) => const MainLayout(initialRoute: '/settings'),
        '/accountSettings': (_) =>
            const MainLayout(initialRoute: '/accountSettings'),
        '/receipt': (_) => const MainLayout(initialRoute: '/receipt'),
        '/notification': (_) => const MainLayout(initialRoute: '/notification'),
        '/gallery': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return MainLayout(
            initialRoute: '/gallery',
            initialArguments: args,
          );
        },
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
        '/receipt/manuel': (_) =>
            const MainLayout(initialRoute: '/receipt/manuel'),
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

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ApiClient().getValidToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;
        if (token != null && token.isNotEmpty) {
          return const MainLayout();
        }

        return const PageLogin();
      },
    );
  }
}
