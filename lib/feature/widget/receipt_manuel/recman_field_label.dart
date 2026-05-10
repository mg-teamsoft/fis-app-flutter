part of '../../page/receipt_manuel_page.dart';

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text)
      : main = null,
        suffix = null;

  const _FieldLabel.rich({
    required this.main,
    required this.suffix,
  }) : text = null;

  final String? text;
  final String? main;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      return ThemeTypography.bodyMedium(
        context,
        text!,
        color: context.colorScheme.onSurface,
      );
    }

    return RichText(
      text: TextSpan(
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: main),
          TextSpan(
            text: suffix,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
