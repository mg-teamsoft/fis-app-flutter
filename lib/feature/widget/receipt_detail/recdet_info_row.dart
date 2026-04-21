part of '../../page/receipt_detail_page.dart';

final class _ReceiptDetailInfoRow extends StatelessWidget {
  const _ReceiptDetailInfoRow({
    required this.label,
    required this.value,
    this.secondaryLabel,
    this.secondaryValue,
  });

  final String label;
  final String value;
  final String? secondaryLabel;
  final String? secondaryValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const ThemePadding.verticalSymmetricSmall(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThemeTypography.bodySmall(
                  context,
                  label,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: ThemeSize.spacingS),
                ThemeTypography.titleMedium(
                  context,
                  value,
                  weight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ],
            ),
          ),
          if (secondaryLabel != null && secondaryValue != null) ...[
            const SizedBox(width: ThemeSize.spacingM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ThemeTypography.bodySmall(
                  context,
                  secondaryLabel!,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: ThemeSize.spacingS),
                ThemeTypography.titleMedium(
                  context,
                  secondaryValue!,
                  weight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
