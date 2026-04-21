part of '../../page/receipt_detail_page.dart';

final class _ReceiptDetailBuilder extends StatefulWidget {
  const _ReceiptDetailBuilder({
    required this.id,
    required this.customerUserId,
    required this.size,
    required this.initDetail,
    required this.currencyFormatter,
    required this.dateFormatter,
  });

  final String id;
  final String? customerUserId;
  final Size size;
  final Future<ModelReceiptDetail> initDetail;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;

  @override
  State<_ReceiptDetailBuilder> createState() => __ReceiptDetailBuilderState();
}

class __ReceiptDetailBuilderState extends State<_ReceiptDetailBuilder> {
  late Future<ModelReceiptDetail> detailPart;

  @override
  void initState() {
    super.initState();
    detailPart = widget.initDetail;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ModelReceiptDetail>(
      future: detailPart,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ReceiptDetailError(
            message: 'Fiş detayı yüklenirken bir hata oluştu.',
            onRetry: () {
              setState(() {
                detailPart = ReceiptApiService().getReceiptDetail(
                  widget.id,
                  customerUserId: widget.customerUserId,
                );
              });
            },
          );
        }

        final detail = snapshot.data;
        if (detail == null) {
          return const _ReceiptDetailError(message: 'Fiş detayı bulunamadı.');
        }

        return ListView(
          padding: const ThemePadding.all20(),
          children: [
            _ReceiptDetailImage(size: widget.size, imageUrl: detail.imageUrl),
            const SizedBox(height: ThemeSize.spacingM),
            ThemeTypography.h4(
              context,
              detail.businessName,
              color: context.colorScheme.onSurface,
            ),
            const SizedBox(height: ThemeSize.spacingS),
            ThemeTypography.h4(
              context,
              widget.currencyFormatter.format(detail.totalAmount),
              color: context.colorScheme.onSurface,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            _InfoCard(
              entries: [
                _ReceiptDetailInfoRow(
                  label: 'Fiş No',
                  value: detail.receiptNumber,
                  secondaryLabel: 'İşlem Tarihi',
                  secondaryValue: detail.transactionDate != null
                      ? widget.dateFormatter.format(detail.transactionDate!)
                      : '—',
                ),
                _DividerRow(),
                _ReceiptDetailInfoRow(
                  label: 'Toplam Tutar',
                  value: widget.currencyFormatter.format(detail.totalAmount),
                ),
                _ReceiptDetailInfoRow(
                  label: 'Toplam KDV Tutarı',
                  value: widget.currencyFormatter.format(detail.vatAmount),
                  secondaryLabel: 'KDV Oranı',
                  secondaryValue: '${detail.vatRate.toStringAsFixed(2)}%',
                ),
                _ReceiptDetailInfoRow(
                  label: 'İşlem Tipi',
                  value: detail.transactionType?.isNotEmpty ?? false
                      ? detail.transactionType!
                      : '—',
                ),
                _ReceiptDetailInfoRow(
                  label: 'Ödeme Tipi',
                  value: detail.paymentType?.isNotEmpty ?? false
                      ? detail.paymentType!
                      : '—',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
