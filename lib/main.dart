import 'dart:async';

import 'pages/excel_files_page.dart';
import 'pages/receipt_process_page.dart';
import 'pages/receipt_results_page.dart';
import 'services/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'pages/receipt_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'dart:developer' as developer;

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
      title: 'Fis App',
      navigatorKey: AuthNavigation.navigatorKey,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const MyHomePage(),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fis App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Giriş başarılı!'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: const Text('Çıkış (örnek)'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ana Sayfa")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Hoşgeldiniz"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReceiptPage()),
                );
              },
              icon: const Icon(Icons.receipt_long), // fiş ikonu
              label: const Text("Fiş Yükleme Sayfasına Git"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExcelFilesPage()),
                );
              },
              icon: const Icon(Icons.table_chart), // excel/tablo ikonu
              label: const Text("Excel Görüntüleme Sayfasına Git"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
