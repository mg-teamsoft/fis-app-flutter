part of '../../page/receipt_gallery_page.dart';

final class _ReceiptGalleryBuildSearchResult extends StatelessWidget {
  const _ReceiptGalleryBuildSearchResult({
    required this.theme,
    required this.openDetails,
    required this.filteredReceipts,
  });

  final Future<void> Function(ModelReceipt) openDetails;
  final List<ModelReceipt> filteredReceipts;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (filteredReceipts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: ThemeTypography.titleMedium(
          context,
          'Sonuç bulunamadı.',
          color: context.colorScheme.onSurface,
          textAlign: TextAlign.center,
        ),
      );
    }

    final dateFormatter = DateFormat('d MMMM yyyy', 'tr_TR');
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: filteredReceipts.length,
      itemBuilder: (context, index) {
        final receipt = filteredReceipts[index];
        final date = receipt.transactionDate;
        final dateText =
            date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
        final amountText = currencyFormatter.format(receipt.totalAmount);

        return Container(
          margin: const ThemePadding.marginBottom16(),
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
              onTap: () async {
                FocusScope.of(context).unfocus();
                await openDetails(receipt);
              },
              child: Padding(
                padding: const ThemePadding.all16(),
                child: Row(
                  children: [
                    Container(
                      padding: const ThemePadding.all10(),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_rounded,
                        color: context.colorScheme.onSurface,
                        size: ThemeSize.iconLarge,
                      ),
                    ),
                    const SizedBox(width: ThemeSize.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ThemeTypography.titleMedium(
                            context,
                            receipt.businessName,
                            weight: FontWeight.w700,
                            color: context.colorScheme.onSurface,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: ThemeSize.spacingS),
                        ],
                      ),
                    ),
                    const SizedBox(width: ThemeSize.spacingS),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ThemeTypography.titleMedium(
                          context,
                          amountText,
                          weight: FontWeight.w800,
                          color: context.colorScheme.onSurface,
                        ),
                        ThemeTypography.titleMedium(
                          context,
                          dateText,
                          color: context.colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
