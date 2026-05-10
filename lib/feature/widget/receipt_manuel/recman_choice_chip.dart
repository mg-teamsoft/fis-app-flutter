part of '../../page/receipt_manuel_page.dart';

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const ThemePadding.horizontalSymmetricMedium(),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.secondary
              : context.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? context.colorScheme.onSecondary
                : context.colorScheme.onSurface,
          ),
        ),
        child: ThemeTypography.bodyLarge(
          context,
          label,
          color: selected
              ? context.colorScheme.onSecondary
              : context.colorScheme.onSurface.withValues(alpha: 0.3),
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}
