part of '../page/receipt_detail.dart';

final class _ReceiptDetailView extends StatelessWidget {
  const _ReceiptDetailView({
    required this.id,
    required this.size,
    required this.detail,
    required this.currencyFormatter,
    required this.dateFormatter,
  });

  final String id;
  final Size size;
  final Future<ModelReceiptDetail> detail;
  final NumberFormat currencyFormatter;
  final DateFormat dateFormatter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ReceiptDetailBuilder(
        id: id,
        size: size,
        initDetail: detail,
        currencyFormatter: currencyFormatter,
        dateFormatter: dateFormatter,
      ),
    );
  }
}
