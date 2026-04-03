part of '../../page/home.dart';

final class _HomeRecentReceipts extends StatelessWidget {
  const _HomeRecentReceipts({required this.model});

  final ModelHome model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormatter = DateFormat('d MMMM', 'tr_TR');

    final receipts = model.recentReceipts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Fişler',
          style: context.textTheme.headlineLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        if (receipts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Text(
              'Aylık işleminiz bulunmuyor.',
              style: theme.textTheme.bodyMedium,
            ),
          )
        else
          ...receipts.map((receipt) {
            final date = receipt.transactionDate;
            final dateText =
                date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
            final amountText = currencyFormatter.format(receipt.totalAmount);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        date,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: theme.colorScheme.surface,
    );
  }
}
