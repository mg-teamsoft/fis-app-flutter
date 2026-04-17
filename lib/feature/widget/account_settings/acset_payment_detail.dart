part of '../../page/account_settings_page.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null && error!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Odeme detaylari alinamadi.',
              style: TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (sortedTransactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Kayıt bulunamadı.'),
          ),
        ...sortedTransactions.map((transaction) {
          final purchaseDate = transaction.purchaseDate != null
              ? dateFormatter.format(transaction.purchaseDate!)
              : '-';
          var expiresDateStr = '-';
          final pId = transaction.productId.toLowerCase();

          if (pId.contains('consumable')) {
            expiresDateStr = '--';
          } else {
            if (transaction.expiresDate != null) {
              expiresDateStr = dateFormatter.format(transaction.expiresDate!);
            } else if (transaction.purchaseDate != null) {
              final d = transaction.purchaseDate!;
              if (pId.contains('monthly')) {
                expiresDateStr = dateFormatter.format(
                  DateTime(d.year, d.month + 1, d.day, d.hour, d.minute),
                );
              } else if (pId.contains('yearly') || pId.contains('annual')) {
                expiresDateStr = dateFormatter.format(
                  DateTime(d.year + 1, d.month, d.day, d.hour, d.minute),
                );
              }
            }
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ürün',
                        style: TextStyle(
                          color: Color(0xFF475467),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        transaction.productId.isNotEmpty
                            ? transaction.productId
                                .replaceAll('.', ' ')
                                .replaceAll('_', ' ')
                                .split(' ')
                                .where((w) => w.isNotEmpty)
                                .map(
                                  (w) =>
                                      w[0].toUpperCase() +
                                      w.substring(1).toLowerCase(),
                                )
                                .join(' ')
                            : '-',
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ürün Tipi',
                        style: TextStyle(
                          color: Color(0xFF475467),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        transaction.productType.isNotEmpty
                            ? ProductTypeEnum.translate(transaction.productType)
                            : '-',
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Platform',
                        style: TextStyle(
                          color: Color(0xFF475467),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        transaction.platform.isNotEmpty
                            ? transaction.platform
                            : '-',
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Satın Alma Tarihi',
                        style: TextStyle(
                          color: Color(0xFF475467),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        purchaseDate,
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bitiş Tarihi',
                        style: TextStyle(
                          color: Color(0xFF475467),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        expiresDateStr,
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
