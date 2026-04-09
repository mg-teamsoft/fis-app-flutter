part of '../page/receipt_detail_page.dart';

final class _ReceiptDetailView extends StatelessWidget {
  const _ReceiptDetailView({
    required this.id,
    required this.customerUserId,
    required this.size,
    required this.detail,
    required this.currencyFormatter,
    required this.dateFormatter,
  });

  final String id;
  final String? customerUserId;
  final Size size;
  final Future<ModelReceiptDetail> detail;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _ReceiptDetailAppbar(),
      body: _ReceiptDetailBuilder(
        id: id,
        customerUserId: customerUserId,
        size: size,
        initDetail: detail,
        currencyFormatter: currencyFormatter,
        dateFormatter: dateFormatter,
      ),
    );
  }
}
