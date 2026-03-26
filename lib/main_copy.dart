import 'dart:async';
import 'dart:developer' as developer;

import 'package:fis_app_flutter/pages/main_layout.dart';
import 'package:fis_app_flutter/providers/purchase_provider.dart';
import 'package:fis_app_flutter/services/auth_navigation.dart';
import 'package:fis_app_flutter/services/purchase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app/import/theme.dart';
import 'pages/reset_password_page.dart';
import 'providers/user_plan_provider.dart';
// ✅ add these imports (adjust paths to your project)
import 'services/api_client.dart';

Future<void> main() async {
  usePathUrlStrategy(); // Enables path-based URLs so /resetPassword?token=... works

  await initializeDateFormatting('tr_TR');

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
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
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),

          // You can add AuthProvider here too (recommended),
          // and any other global providers.
        ],
        child: Builder(builder: (newContext) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Fiş App',
            theme: ThemeApp.light,
            themeMode: newContext.watch<ThemeProvider>().themeMode,
            darkTheme: ThemeApp.dark,
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
            initialRoute: kIsWeb ? null : '/login',
            routes: {
              '/': (_) => const ResetPasswordPage(),
              '/login': (_) => const ResetPasswordPage(),
              '/register': (_) => const ResetPasswordPage(),
              '/home': (_) => const MainLayout(initialRoute: '/home'),
              '/receipt': (_) => const MainLayout(initialRoute: '/receipt'),
              '/excelFiles': (_) =>
                  const MainLayout(initialRoute: '/excelFiles'),
              '/connections': (_) =>
                  const MainLayout(initialRoute: '/connections'),
              '/about': (_) => const MainLayout(initialRoute: '/about'),
              '/gallery': (_) => const MainLayout(initialRoute: '/gallery'),
              '/settings': (_) => const MainLayout(initialRoute: '/settings'),
              '/accountSettings': (_) =>
                  const MainLayout(initialRoute: '/accountSettings'),
              '/forgotPassword': (_) => const ResetPasswordPage(),
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
              '/receipt/manuel': (_) =>
                  const MainLayout(initialRoute: '/receipt/manuel'),
            },
            onGenerateRoute: (settings) {
              final uri = Uri.tryParse(settings.name ?? '');
              if (uri != null && uri.path == '/resetPassword') {
                final token = uri.queryParameters['token'] ??
                    (settings.arguments as String?);
                return MaterialPageRoute(
                  builder: (_) => ResetPasswordPage(initialToken: token),
                  settings: settings,
                );
              }
              return null;
            },
          );
        }));
  }
}
