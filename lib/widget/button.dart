import 'package:flutter/material.dart';
import 'package:fis_app_flutter/theme/theme.dart';

class WidgetButton extends StatelessWidget {
  const WidgetButton(
      {super.key,
      required this.text,
      this.radius = const BorderRadiusGeometry.all(Radius.circular(8.0)),
      required this.onPressed,
      this.size = const Size(120, 40),
      this.color,
      required this.icon});
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
            backgroundColor: color ?? context.appTheme.brandSecondary,
            padding: ThemePadding.all10(),
            minimumSize: size),
        child: Row(
            spacing: ThemeSize.spacingS,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: ThemeSize.iconLarge),
              ThemeTypography.h4(context, text,
                  color: context.colorScheme.onSecondary),
            ]));
  }
}
