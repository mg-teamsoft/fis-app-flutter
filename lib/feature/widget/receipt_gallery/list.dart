part of '../../page/receipt_gallery.dart';

final class _ReceiptsList extends StatelessWidget {
  const _ReceiptsList({
    required this.receipts,
    required this.onOpenDetails,
  });

  final List<ModelReceipt> receipts;
  final void Function(ModelReceipt) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMMM', 'tr_TR');
    final monthFormatter = DateFormat('MMMM yyyy', 'tr_TR');
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    final grouped = <DateTime?, List<ModelReceipt>>{};
    for (final receipt in receipts) {
      final date = receipt.transactionDate;
      final key = (date == null)
          ? null
          : DateTime(date.year, date.month); // normalize to month
      grouped.putIfAbsent(key, () => []).add(receipt);
    }

    final groups = grouped.entries.map((entry) {
      final items = [...entry.value]..sort((a, b) {
          final aDate =
              a.transactionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate =
              b.transactionDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      final label = entry.key != null
          ? capitalize(monthFormatter.format(entry.key!))
          : 'Tarihsiz';
      return _ReceiptMonthGroup(label: label, items: items, sortKey: entry.key);
    }).toList()
      ..sort((a, b) {
        if (a.sortKey == null && b.sortKey == null) return 0;
        if (a.sortKey == null) return 1;
        if (b.sortKey == null) return -1;
        return b.sortKey!.compareTo(a.sortKey!);
      });

    final children = <Widget>[];

    for (final group in groups) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            group.label,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      for (final receipt in group.items) {
        final date = receipt.transactionDate;
        final dateText =
            date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _ReceiptListTile(
              summary: receipt,
              dateText: dateText,
              amountText: currencyFormatter.format(receipt.totalAmount),
              onOpenDetails: onOpenDetails,
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }
}
