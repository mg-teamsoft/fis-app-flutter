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
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: ThemeRadius.circular12,
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
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
      ],
    );
  }
}

final class _InvoiceItem extends StatelessWidget {
  const _InvoiceItem({
    required this.title,
    required this.date,
    required this.amount,
  });

  final String title;
  final String date;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.receipt_long, color: context.colorScheme.primary),
      title: ThemeTypography.bodyMedium(
        context,
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        weight: FontWeight.w600,
        color: context.colorScheme.onSurfaceVariant,
      ),
      subtitle: ThemeTypography.bodySmall(
        context,
        date,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        color: context.colorScheme.onSurfaceVariant,
      ),
      trailing: ThemeTypography.bodyMedium(
        context,
        amount,
        weight: FontWeight.w500,
        color: context.colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: ThemeRadius.circular12,
      ),
      tileColor: context.colorScheme.surface,
    );
  }
}
