import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class WidgetPopMenuItem extends PopupMenuItem<String> {
  // Verileri constructor'da alıyoruz
  final String text;
  final IconData icon;
  final bool isDestructive;

  WidgetPopMenuItem({
    super.key,
    required String value,
    required this.text,
    required this.icon,
    this.isDestructive = false,
  }) : super(
          value: value,
          child: _MenuItemContent(
            text: text,
            icon: icon,
            isDestructive: isDestructive,
          ),
        );
}

class _MenuItemContent extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDestructive;

  const _MenuItemContent({
    required this.text,
    required this.icon,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: ThemeSize.iconLarge,
          color: isDestructive
              ? context.theme.error
              : context.theme.brandSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isDestructive
                ? context.theme.error
                : context.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
