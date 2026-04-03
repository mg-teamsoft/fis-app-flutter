part of '../../page/account_settings.dart';

class _AccountSettingsPaymentDetailsTable extends StatelessWidget {
  const _AccountSettingsPaymentDetailsTable({
    required this.transactions,
    required this.error,
  });

  final List<PurchaseTransaction> transactions;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMM yyyy HH:mm', 'tr_TR');

    final sortedTransactions = [...transactions]..sort((a, b) {
        final aDate = a.purchaseDate ??
            a.expiresDate ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.purchaseDate ??
            b.expiresDate ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    final rows = sortedTransactions.isEmpty
        ? <DataRow>[
            const DataRow(
              cells: [
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
              ],
            ),
          ]
        : sortedTransactions.map((transaction) {
            final purchaseDate = transaction.purchaseDate != null
                ? dateFormatter.format(transaction.purchaseDate!)
                : '-';
            final expiresDate = transaction.expiresDate != null
                ? dateFormatter.format(transaction.expiresDate!)
                : '-';
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    transaction.transactionId.isNotEmpty
                        ? transaction.transactionId
                        : '-',
                  ),
                ),
                DataCell(
                  Text(
                    transaction.originalTransactionId.isNotEmpty
                        ? transaction.originalTransactionId
                        : '-',
                  ),
                ),
                DataCell(Text(purchaseDate)),
                DataCell(Text(expiresDate)),
              ],
            );
          }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error != null && error!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Text(
                'Odeme detaylari alinamadi.',
                style: TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('transactionId')),
                DataColumn(label: Text('originalTransactionId')),
                DataColumn(label: Text('purchaseDate')),
                DataColumn(label: Text('expiresDate')),
              ],
              rows: rows,
            ),
          ),
        ],
      ),
    );
  }
}
