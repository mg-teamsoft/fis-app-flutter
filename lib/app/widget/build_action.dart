import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class BuildActionButton extends StatelessWidget {
  const BuildActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    super.key,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ThemeSize.buttonHeightMedium,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: ThemeSize.iconMedium,
        ),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.onPrimary,
          padding: const ThemePadding.verticalSymmetricMedium(),
          textStyle: ThemeTypography.bodyLarge(
            context,
            '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ).style,
          shape: RoundedRectangleBorder(
            borderRadius: ThemeRadius.circular12,
          ),
        ),
      ),
    );
  }
}
