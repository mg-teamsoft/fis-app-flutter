import 'package:fis_app_flutter/pages/forgot_password_page.dart';
import 'package:fis_app_flutter/pages/login_page.dart';
import 'package:fis_app_flutter/pages/main_layout.dart';
import 'package:fis_app_flutter/pages/register_page.dart';
import 'package:fis_app_flutter/services/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'pages/reset_password_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };
  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stack) {
      // log to console / Sentry, etc.
      developer.log('Uncaught: $error\n$stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Fiş App',
      navigatorKey: AuthNavigation.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // optional
      ),
      initialRoute: kIsWeb ? null : '/login',
      routes: {
        '/': (_) => const LoginPage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const MainLayout(initialRoute: '/home'),
        '/receipt': (_) => const MainLayout(initialRoute: '/receipt'),
        '/excelFiles': (_) => const MainLayout(initialRoute: '/excelFiles'),
        '/about': (_) => const MainLayout(initialRoute: '/about'),
        '/gallery': (_) => const MainLayout(initialRoute: '/gallery'),
        '/settings': (_) => const MainLayout(initialRoute: '/settings'),
        '/accountSettings': (_) =>
            const MainLayout(initialRoute: '/accountSettings'),
        '/forgotPassword': (_) => const ForgotPasswordPage(),
        '/resetPassword': (_) => const ResetPasswordPage(),
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
      },
      onGenerateRoute: (settings) {
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri != null && uri.path == '/resetPassword') {
          final token =
              uri.queryParameters['token'] ?? (settings.arguments as String?);
          return MaterialPageRoute(
            builder: (_) => ResetPasswordPage(initialToken: token),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
