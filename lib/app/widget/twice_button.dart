import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class TwiceButton extends StatelessWidget {
  const TwiceButton({
    required this.size,
    required this.onPressedOne,
    required this.onPressedTwo,
    required this.titleOne,
    required this.titleTwo,
    this.iconOne,
    this.iconTwo,
    this.textStyle,
    this.backgroundColorOne,
    this.backgroundColorTwo,
    super.key,
  });

  final Size size;
  final VoidCallback onPressedOne;
  final VoidCallback onPressedTwo;
  final String titleOne;
  final String titleTwo;
  final Widget? iconOne;
  final Widget? iconTwo;
  final Color? backgroundColorOne;
  final Color? backgroundColorTwo;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildItem(
          context,
          title: titleOne,
          icon: iconOne,
          onTap: onPressedOne,
          color: backgroundColorOne ?? context.colorScheme.primaryContainer,
        ),
        const SizedBox(width: ThemeSize.spacingS),
        _buildItem(
          context,
          title: titleTwo,
          icon: iconTwo,
          onTap: onPressedTwo,
          color: backgroundColorTwo ?? context.colorScheme.primaryContainer,
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required Widget? icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: ThemeRadius.circular8,
          ),
          padding: const ThemePadding.all16(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              child: icon ?? const SizedBox(),
            ),
            const SizedBox(height: ThemeSize.spacingM),
            Text(
              title,
              style: (textStyle ?? context.textTheme.bodyLarge)?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
