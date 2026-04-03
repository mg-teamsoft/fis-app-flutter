import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class WidgetPopMenu<T> extends StatelessWidget {
  const WidgetPopMenu({
    required this.menuitems,
    required this.icon,
    required this.onSelected,
    super.key,
  });
  final List<PopupMenuItem<T>> menuitems;
  final IconData icon;
  final void Function(T)? onSelected;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      shape: RoundedRectangleBorder(borderRadius: ThemeRadius.bottom16),
      elevation: 8,
      icon: Icon(
        icon,
      ),
      offset: const Offset(0, 45),
      onSelected: onSelected,
      itemBuilder: (context) => menuitems,
    );
  }
}
