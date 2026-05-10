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
    final dateFormatter = DateFormat('dd.MM.yy', 'tr_TR');

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
          Padding(
            padding: const ThemePadding.marginBottom10(),
            child: ThemeTypography.bodyLarge(
              context,
              'Ödeme detayları alınamadı.',
              color: context.theme.error,
              weight: FontWeight.w600,
            ),
          ),
        ],
        if (sortedTransactions.isEmpty)
          Padding(
            padding: const ThemePadding.all16(),
            child: ThemeTypography.bodyLarge(
              context,
              'Kayıt bulunamadı.',
              color: context.colorScheme.onSurface,
            ),
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
            margin: const ThemePadding.marginBottom12(),
            shape: RoundedRectangleBorder(
              borderRadius: ThemeRadius.circular12,
              side: BorderSide(color: context.theme.divider),
            ),
            elevation: 0,
            color: context.colorScheme.surface,
            child: Padding(
              padding: const ThemePadding.all16(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(
                    context,
                    'Ürün',
                    transaction.productId.isNotEmpty
                        ? transaction.productId.split('.').last
                        : '-',
                  ),
                  const SizedBox(height: ThemeSize.spacingXs),
                  _buildRow(
                    context,
                    'Ürün Tipi',
                    transaction.productType.isNotEmpty
                        ? ProductTypeEnum.translate(transaction.productType)
                        : '-',
                  ),
                  const SizedBox(height: ThemeSize.spacingXs),
                  _buildRow(
                    context,
                    'Platform',
                    transaction.platform.isNotEmpty
                        ? transaction.platform
                        : '-',
                  ),
                  const SizedBox(height: ThemeSize.spacingXs),
                  _buildRow(context, 'Satın Alma', purchaseDate),
                  const SizedBox(height: ThemeSize.spacingXs),
                  _buildRow(context, 'Bitiş', expiresDateStr),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ThemeTypography.bodyMedium(
            context,
            label,
            color: context.colorScheme.onSurfaceVariant,
            weight: FontWeight.w500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: ThemeSize.spacingM),
        Flexible(
          child: ThemeTypography.bodyMedium(
            context,
            value,
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
