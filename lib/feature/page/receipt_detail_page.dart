import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/receipt_api_service.dart';
import 'package:fis_app_flutter/feature/model/receipt_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part '../controller/receipt_detail_controller.dart';
part '../view/receipt_detail_view.dart';
part '../widget/receipt_detail/recdet_appbar.dart';
part '../widget/receipt_detail/recdet_builder.dart';
part '../widget/receipt_detail/recdet_divider_row.dart';
part '../widget/receipt_detail/recdet_error.dart';
part '../widget/receipt_detail/recdet_image.dart';
part '../widget/receipt_detail/recdet_image_placeholder.dart';
part '../widget/receipt_detail/recdet_info_card.dart';
part '../widget/receipt_detail/recdet_info_row.dart';

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
