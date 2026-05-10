import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class CheckBoxTile extends StatelessWidget {
  const CheckBoxTile({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const ThemePadding.verticalSymmetricSmall(),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.secondary),
        borderRadius: ThemeRadius.circular12,
      ),
      child: CheckboxListTile(
        title: ThemeTypography.bodyLarge(
          context,
          title,
          color: context.colorScheme.onSurface,
        ),
        value: value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: ThemeRadius.circular12),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
