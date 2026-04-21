part of '../../page/receipt_manuel_page.dart';

class _DateFieldBox extends StatelessWidget {
  const _DateFieldBox({
    required this.value,
    required this.onTap,
    this.hasError = false,
  });

  final String value;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ThemeRadius.circular16,
      child: Ink(
        padding: const ThemePadding.horizontalSymmetricMedium(),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: ThemeRadius.circular16,
          border: Border.all(
            color: hasError ? context.theme.error : context.colorScheme.surface,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ThemeTypography.bodyMedium(
                context,
                value.isEmpty ? 'gg/aa/yyyy' : value,
                color: value.isEmpty
                    ? context.colorScheme.onSurfaceVariant
                    : context.colorScheme.onSurface,
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: ThemeSize.iconMedium),
          ],
        ),
      ),
    );
  }
}
