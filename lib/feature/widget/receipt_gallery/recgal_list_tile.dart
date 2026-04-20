part of '../../page/receipt_gallery_page.dart';

final class _ReceiptListTile extends StatelessWidget {
  const _ReceiptListTile({
    required this.summary,
    required this.dateText,
    required this.amountText,
    required this.onOpenDetails,
  });

  final ModelReceipt summary;
  final String dateText;
  final String amountText;
  final void Function(ModelReceipt) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const ThemePadding.marginBottom12(),
      decoration: BoxDecoration(
        borderRadius: ThemeRadius.circular16,
        gradient: LinearGradient(
          colors: [
            context.colorScheme.surface,
            context.colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: ThemeRadius.circular16,
        child: InkWell(
          borderRadius: ThemeRadius.circular16,
          onTap: () => onOpenDetails(summary),
          child: Padding(
            padding: const ThemePadding.all16(),
            child: Row(
              children: [
                Container(
                  padding: const ThemePadding.all10(),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius: ThemeRadius.circular12,
                  ),
                  child: Icon(
                    Icons.receipt_rounded,
                    color: context.colorScheme.onSurface,
                    size: ThemeSize.iconLarge,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ThemeTypography.titleMedium(
                    context,
                    summary.businessName,
                    weight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: ThemeSize.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ThemeTypography.titleMedium(
                        context,
                        amountText,
                        weight: FontWeight.w800,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(height: ThemeSize.spacingS),
                      ThemeTypography.bodyMedium(
                        context,
                        dateText,
                        color: context.colorScheme.onSurface,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
