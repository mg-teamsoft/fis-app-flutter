import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class TwiceButton extends StatelessWidget {
  const TwiceButton({
    required this.size,
    required this.onPressedOne,
    required this.onPressedTwo,
    required this.titleOne,
    required this.titleTwo,
    required this.iconOne,
    required this.iconTwo,
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
  final Widget iconOne;
  final Widget iconTwo;
  final Color? backgroundColorOne;
  final Color? backgroundColorTwo;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    const edgePadding = 24.0 * 2;
    final itemWidth = (size.width - edgePadding - ThemeSize.spacingS) * 0.4;
    final itemHeight = (size.height - edgePadding - ThemeSize.spacingS) * 0.2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildItem(
          context,
          width: itemWidth,
          height: itemHeight,
          title: titleOne,
          icon: iconOne,
          onTap: onPressedOne,
          color: backgroundColorOne ?? context.colorScheme.primaryContainer,
        ),
        const SizedBox(width: ThemeSize.spacingS),
        _buildItem(
          context,
          width: itemWidth,
          height: itemHeight,
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
    required Widget icon,
    required double width,
    required double height,
    required VoidCallback onTap,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: ThemeRadius.circular24,
          ),
          padding: const ThemePadding.all16(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: ThemeSize.spacingS),
            Text(
              title,
              style: (textStyle ?? context.textTheme.bodyMedium)?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
