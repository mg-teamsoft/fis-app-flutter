part of '../page/receipt_detail_page.dart';

mixin _ConnectionReceiptDetail on State<PageReceiptDetail> {
  late Future<ModelReceiptDetail> _detail;
  late NumberFormat _currencyFormatter;
  late DateFormat _dateFormatter;
  late Size _size;

  @override
  void initState() {
    super.initState();
    _currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    _dateFormatter = DateFormat('d MMMM yyyy', 'tr_TR');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detail = ReceiptApiService().getReceiptDetail(
      widget.receiptId,
      customerUserId: widget.customerUserId,
    );
    _size = MediaQuery.of(context).size;
  }
}
