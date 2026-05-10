import 'package:fis_app_flutter/app/import/page.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/providers/user_plan_provider.dart';
import 'package:fis_app_flutter/app/services/auth_service.dart';
import 'package:fis_app_flutter/app/widget/scaffold.dart';
import 'package:fis_app_flutter/model/receipt_flow_models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

part './mixin_main_layout.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    this.initialRoute = '/home',
    this.initialArguments,
  });

  final String initialRoute;
  final Object? initialArguments;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with _MixinMainLayout {
  @override
  Widget build(BuildContext context) {
    final child = _buildCurrentPage(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_routeHistory.isNotEmpty || _currentRoute != '/home') {
          _onBackPressed();
        } else {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          }
        }
      },
      child: WidgetScaffold(
        onSelected: _handleMenuSelection,
        currentIndex: _currentNavIndex,
        onTabSelected: _onTabTapped,
        showBackButton: _currentNavIndex > 6 && _routeHistory.isNotEmpty,
        onBackPressed: _onBackPressed,
        body: SafeArea(child: child),
      ),
    );
  }
}
