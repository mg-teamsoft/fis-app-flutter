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
      children: [
        Expanded(
          child: _buildItem(
            context,
            title: titleOne,
            icon: iconOne,
            onTap: onPressedOne,
            color: backgroundColorOne ?? context.colorScheme.primaryContainer,
          ),
        ),
        const SizedBox(width: ThemeSize.spacingS),
        Expanded(
          child: _buildItem(
            context,
            title: titleTwo,
            icon: iconTwo,
            onTap: onPressedTwo,
            color: backgroundColorTwo ?? context.colorScheme.primaryContainer,
          ),
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
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: ThemeRadius.circular8,
        ),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: const IconThemeData(size: 18),
              child: icon,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              title.trim(),
              style: (textStyle ?? context.textTheme.bodyMedium)?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
