import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/feature/model/receipt_detail.dart';
import 'package:fis_app_flutter/services/receipt_api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part '../connection/receipt_detail.dart';
part '../view/receipt_detail.dart';
part '../widget/receipt_detail/builder.dart';
part '../widget/receipt_detail/divider_row.dart';
part '../widget/receipt_detail/error.dart';
part '../widget/receipt_detail/image.dart';
part '../widget/receipt_detail/image_placeholder.dart';
part '../widget/receipt_detail/info_card.dart';
part '../widget/receipt_detail/info_row.dart';

class PageReceiptDetail extends StatefulWidget {
  const PageReceiptDetail({required this.receiptId, super.key});

  final String receiptId;

  @override
  State<PageReceiptDetail> createState() => _PageReceiptDetailState();
}

class _PageReceiptDetailState extends State<PageReceiptDetail>
    with _ConnectionReceiptDetail {
  @override
  Widget build(BuildContext context) {
    return _ReceiptDetailView(
      id: widget.receiptId,
      size: _size,
      detail: _detail,
      currencyFormatter: _currencyFormatter,
      dateFormatter: _dateFormatter,
    );
  }
}
