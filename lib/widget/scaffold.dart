import 'package:fis_app_flutter/services/receipt_service.dart';
import 'package:fis_app_flutter/widget/appbar.dart';
import 'package:fis_app_flutter/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:fis_app_flutter/theme/theme.dart';

class WidgetScaffold<T> extends StatelessWidget {
  const WidgetScaffold({
    super.key,
    required this.onSelected,
    required this.currentIndex,
    required this.onTabSelected,
    required this.showBackButton,
    required this.body,
  });
  final Widget body;
  final void Function(String)? onSelected;
  final int currentIndex;
  final Function(int) onTabSelected;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: context.appTheme.brandPrimary,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: context.colorScheme.secondary,
        onPressed: () async => await ReceiptService.captureWithCamera(context),
        child: Icon(Icons.camera_alt_rounded,
            color: context.colorScheme.onSecondary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:
          WidgetBottomBar(currentIndex: currentIndex, onTap: onTabSelected),
      appBar:
          WidgetAppbar(showBackButton: showBackButton, onSelected: onSelected),
      body: Padding(padding: ThemePadding.all16(), child: body),
    );
  }
}
