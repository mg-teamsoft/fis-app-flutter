import 'package:fis_app_flutter/models/receipt_flow_models.dart';
import 'package:fis_app_flutter/page/home.dart';
import 'package:fis_app_flutter/page/receipt_gallery.dart';
import 'package:fis_app_flutter/pages/about_page.dart';
import 'package:fis_app_flutter/pages/account_settings_page.dart';
import 'package:fis_app_flutter/pages/excel_files_page.dart';
import 'package:fis_app_flutter/pages/home_page.dart';
import 'package:fis_app_flutter/pages/receipt_gallery_page.dart';
import 'package:fis_app_flutter/pages/receipt_page.dart';
import 'package:fis_app_flutter/pages/receipt_process_page.dart';
import 'package:fis_app_flutter/pages/receipt_results_page.dart';
import 'package:fis_app_flutter/pages/settings_page.dart';
import 'package:fis_app_flutter/providers/user_plan_provider.dart';
import 'package:fis_app_flutter/services/auth_service.dart';
import 'package:fis_app_flutter/widget/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  final String initialRoute;
  final Object? initialArguments;

  const MainLayout({
    super.key,
    this.initialRoute = '/home',
    this.initialArguments,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final _auth = AuthService();

  late String _currentRoute;
  Object? _currentArguments;

  static const List<String> _navRoutes = [
    '/home',
    '/gallery',
    '/excelFiles',
    '/settings',
  ];

  static const Set<String> _shellRoutes = {
    '/home',
    '/gallery',
    '/excelFiles',
    '/about',
    '/accountSettings',
    '/settings',
  };

  late final Map<String, Widget Function(BuildContext, Object?)> _pageBuilders =
      {
    '/home': (_, __) => const PageHome(),
    '/receipt': (_, __) => const ReceiptPage(),
    '/excelFiles': (_, __) => const ExcelFilesPage(),
    '/about': (_, __) => const AboutPage(),
    '/accountSettings': (_, __) => const AccountSettingsPage(),
    '/gallery': (_, __) => PageReceiptGallery(),
    '/settings': (_, __) => const SettingsPage(),
    '/receipt/process': (_, args) {
      final files = (args is List<XFile>) ? args : const <XFile>[];
      return ReceiptProcessPage(files: files);
    },
    '/receipt/results': (_, args) {
      final items =
          (args is List<SelectedItem>) ? args : const <SelectedItem>[];
      return ReceiptResultsPage(items: items);
    },
  };

  @override
  void initState() {
    super.initState();
    _currentRoute = _normalizeRoute(widget.initialRoute);
    _currentArguments = widget.initialArguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserPlanProvider>().loadMyPlan();
    });
  }

  String _normalizeRoute(String route) {
    return _pageBuilders.containsKey(route) ? route : '/home';
  }

  void _setCurrentRoute(String route, {Object? arguments}) {
    final normalized = _normalizeRoute(route);
    setState(() {
      _currentRoute = normalized;
      _currentArguments = arguments;
    });
  }

  Widget _buildCurrentPage(BuildContext context) {
    final builder = _pageBuilders[_currentRoute];
    if (builder == null) {
      return const Center(child: Text('Sayfa bulunamadı'));
    }
    return builder(context, _currentArguments);
  }

  void _onTabTapped(int index) {
    if (index < 0 || index >= _navRoutes.length) return;
    final route = _navRoutes[index];
    if (route == _currentRoute) return;
    _setCurrentRoute(route);
  }

  int get _currentNavIndex {
    final index = _navRoutes.indexOf(_currentRoute);
    if (index >= 0) {
      return index;
    }
    return 0;
  }

  void _handleMenuSelection(String value) {
    if (value == 'logout') {
      _auth.logout();
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _setCurrentRoute(value);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: PopupMenuButton<String>(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onSelected: _handleMenuSelection,
        itemBuilder: (context) => const [
          PopupMenuItem(value: '/home', child: Text('Ana Sayfa')),
          PopupMenuItem(value: '/gallery', child: Text('Fişler')),
          PopupMenuItem(value: '/excelFiles', child: Text('Kişiler')),
          PopupMenuItem(value: '/settings', child: Text('Ayarlar')),
        ],
      ),
      title: Image.asset('assets/icon/AppIcon.png', height: 40),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, color: Colors.black),
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => const [
            PopupMenuItem(value: '/about', child: Text('Uygulama Hakkında')),
            PopupMenuItem(
                value: '/accountSettings', child: Text('Hesap Ayarları')),
            PopupMenuItem(value: 'logout', child: Text('Çıkış Yap')),
          ],
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: _onTabTapped,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long), label: "Fişler"),
        BottomNavigationBarItem(
            icon: Icon(Icons.table_chart), label: "Kişiler"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ayarlar"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildCurrentPage(context);
    if (!_shellRoutes.contains(_currentRoute)) {
      return child;
    }

    return WidgetScaffold(
        onSelected: _handleMenuSelection,
        currentIndex: _currentNavIndex,
        onTabSelected: (index) => _onTabTapped(index),
        showBackButton: _currentNavIndex == 0 ? false : true,
        body: SafeArea(child: child));
  }
}
