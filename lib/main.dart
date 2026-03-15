import 'package:fis_app_flutter/pages/forgot_password_page.dart';
import 'package:fis_app_flutter/pages/login_page.dart';
import 'package:fis_app_flutter/pages/main_layout.dart';
import 'package:fis_app_flutter/pages/register_page.dart';
import 'package:fis_app_flutter/providers/purchase_provider.dart';
import 'package:fis_app_flutter/services/auth_navigation.dart';
import 'package:fis_app_flutter/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'pages/reset_password_page.dart';

import 'package:provider/provider.dart';

// ✅ add these imports (adjust paths to your project)
import 'services/api_client.dart';
import 'providers/user_plan_provider.dart';

Future<void> main() async {
  usePathUrlStrategy(); // Enables path-based URLs so /resetPassword?token=... works
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
      developer.log('Uncaught: $error\n$stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ 1) Single ApiClient instance for the whole app
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),

        // ✅ 2) UserPlanProvider app-wide (uses the same ApiClient)
        ChangeNotifierProvider<UserPlanProvider>(
          create: (ctx) => UserPlanProvider(ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider<PurchaseProvider>(
          create: (ctx) => PurchaseProvider(
            PurchaseService(userPlanProvider: ctx.read<UserPlanProvider>()),
            ctx.read<UserPlanProvider>(),
          ),
        ),

        // You can add AuthProvider here too (recommended),
        // and any other global providers.
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Fiş App',
        navigatorKey: AuthNavigation.navigatorKey,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
          Locale('tr', 'TR'),
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
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
      ),
    );
  }
}
