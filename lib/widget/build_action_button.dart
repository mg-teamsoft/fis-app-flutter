import 'package:fis_app_flutter/theme/theme.dart';
import 'package:flutter/material.dart';

class WidgetBuildActionButton extends StatelessWidget {
  const WidgetBuildActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon,size: ThemeSize.iconMedium,),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.secondary,
          foregroundColor: context.colorScheme.onSecondary,
          padding: ThemePadding.verticalSymmetricMedium(),
          textStyle: ThemeTypography.bodyLarge(context, '',style: TextStyle(fontWeight: FontWeight.w600),).style,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

