import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class WidgetPopMenuItem extends PopupMenuItem<String> {
  WidgetPopMenuItem({
    required String value,
    required this.text,
    required this.icon,
    super.key,
    this.isDestructive = false,
  }) : super(
          value: value,
          child: _MenuItemContent(
            text: text,
            icon: icon,
            isDestructive: isDestructive,
          ),
        );
  final String text;
  final IconData icon;
  final bool isDestructive;
}

class _MenuItemContent extends StatelessWidget {
  const _MenuItemContent({
    required this.text,
    required this.icon,
    required this.isDestructive,
  });
  final String text;
  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: ThemeSize.iconLarge,
          color: isDestructive
              ? context.theme.error
              : context.colorScheme.onSurface,
        ),
        const SizedBox(width: ThemeSize.spacingS),
        ThemeTypography.bodyMedium(
          context,
          text,
          color: isDestructive
              ? context.theme.error
              : context.colorScheme.onSurface,
          weight: FontWeight.w500,
        ),
      ],
    );
  }
}
