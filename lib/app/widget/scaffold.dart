import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/receipt_service.dart';
import 'package:fis_app_flutter/app/widget/appbar/appbar.dart';
import 'package:fis_app_flutter/app/widget/bottombar.dart';
import 'package:flutter/material.dart';

class WidgetScaffold extends StatelessWidget {
  const WidgetScaffold({
    required this.onSelected,
    required this.currentIndex,
    required this.onTabSelected,
    required this.showBackButton,
    required this.body,
    this.onBackPressed,
    super.key,
  });
  final Widget body;
  final void Function(String)? onSelected;
  final int currentIndex;
  final void Function(int) onTabSelected;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async => ReceiptService.captureWithCamera(context),
        child: Icon(
          Icons.camera_alt_rounded,
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:
          WidgetBottomBar(currentIndex: currentIndex, onTap: onTabSelected),
      appBar: WidgetAppbar(
        showBackButton: showBackButton,
        onSelected: onSelected,
        onBackPressed: onBackPressed,
      ),
      body: Padding(padding: const ThemePadding.all16(), child: body),
    );
  }
}
