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
              ? context.colorScheme.onPrimary
              : context.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? context.colorScheme.onPrimary
                : context.colorScheme.onSurface,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? context.colorScheme.primary
                : context.colorScheme.surfaceContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
