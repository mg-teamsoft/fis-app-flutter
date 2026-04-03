import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class WidgetButton extends StatelessWidget {
  const WidgetButton({
    required this.text,
    required this.onPressed,
    required this.icon,
    super.key,
    this.radius = const BorderRadiusGeometry.all(Radius.circular(8)),
    this.size = const Size(120, 40),
    this.color,
  });
  final String text;
  final void Function() onPressed;

  final Size size;
  final BorderRadiusGeometry radius;
  final Color? color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: radius),
        backgroundColor: color ?? context.theme.brandSecondary,
        padding: const ThemePadding.all10(),
        minimumSize: size,
      ),
      child: Row(
        spacing: ThemeSize.spacingS,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: ThemeSize.iconLarge),
          ThemeTypography.h4(
            context,
            text,
            color: context.colorScheme.onSecondary,
          ),
        ],
      ),
    );
  }
}
