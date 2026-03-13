import 'package:flutter/material.dart';
import 'package:fis_app_flutter/theme/theme.dart';

class WidgetPopMenu<T> extends StatelessWidget {
  const WidgetPopMenu(
      {super.key,
      required this.menuitems,
      required this.icon,
      required this.onSelected});
  final List<PopupMenuItem<T>> menuitems;
  final IconData icon;
  final void Function(T)? onSelected;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
        shape: RoundedRectangleBorder(borderRadius: ThemeRadius.bottom16),
        color: context.appTheme.brandPrimary,
        elevation: 8,
        icon: Icon(icon, color: context.appTheme.brandSecondary),
        onSelected: onSelected,
        itemBuilder: (BuildContext context) => menuitems);
  }
}
