part of '../../page/home_page.dart';

final class _HomeRecentReceipts extends StatelessWidget {
  const _HomeRecentReceipts({required this.model});

  final ModelHome model;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormatter = DateFormat('d MMMM', 'tr_TR');

    final receipts = model.recentReceipts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThemeTypography.h4(
          context,
          'Son Fişler',
          weight: FontWeight.w900,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: ThemeSize.spacingM),
        if (receipts.isEmpty)
          Container(
            padding: const ThemePadding.all16(),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: ThemeRadius.circular12,
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            alignment: Alignment.center,
            child: ThemeTypography.bodyMedium(
              context,
              'Aylık işleminiz bulunmuyor.',
              color: context.colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...receipts.map((receipt) {
            final date = receipt.transactionDate;
            final dateText =
                date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
            final amountText = currencyFormatter.format(receipt.totalAmount);

            return Padding(
              padding: const ThemePadding.marginBottom8(),
              child: _InvoiceItem(
                title: receipt.businessName,
                date: dateText,
                amount: amountText,
              ),
            );
          }),
        const SizedBox(height: ThemeSize.spacingXXXl),
      ],
    );
  }
}
