part of '../page/receipt_detail.dart';

mixin _ConnectionReceiptDetail on State<PageReceiptDetail> {
  late Future<ModelReceiptDetail> _detail;
  late NumberFormat _currencyFormatter;
  late DateFormat _dateFormatter;
  late Size _size;

  @override
  void initState() {
    super.initState();
    _detail = ReceiptApiService().getReceiptDetail(widget.receiptId);
    _currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    _dateFormatter = DateFormat('d MMMM yyyy', 'tr_TR');
    _size = MediaQuery.of(context).size;
  }
}
