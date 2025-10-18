import 'package:fis_app_flutter/pages/about_page.dart';
import 'package:fis_app_flutter/pages/excel_files_page.dart';
import 'package:fis_app_flutter/pages/home_page.dart';
import 'package:fis_app_flutter/pages/login_page.dart';
import 'package:fis_app_flutter/pages/receipt_page.dart';
import 'package:fis_app_flutter/pages/receipt_process_page.dart';
import 'package:fis_app_flutter/pages/receipt_results_page.dart';
import 'package:fis_app_flutter/pages/register_page.dart';
import 'package:fis_app_flutter/services/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Fiş App',
      navigatorKey: AuthNavigation.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // optional
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomePage(),
        '/about': (_) => const AboutPage(),
        '/receipt': (_) => const ReceiptPage(),
        '/receipt/process': (_) =>
            const ReceiptProcessPage(files: []), // placeholder
        '/receipt/results': (_) =>
            const ReceiptResultsPage(items: []), // placeholder
        '/excelFiles': (_) => const ExcelFilesPage(),
      },
    );
  }
}
