import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/feature/page/receipt_result.dart';
import 'package:flutter/material.dart';

part '../controller/receipt_table.dart';
part '../view/receip_table.dart';
part '../widget/receipt_table/extra_field.dart';
part '../widget/receipt_table/input_decoration.dart';
part '../widget/receipt_table/main_field.dart';
part '../widget/receipt_table/text_row.dart';

class PageReceiptTable extends StatefulWidget {
  const PageReceiptTable({
    required this.data,
    required this.onChanged,
    required this.showErrors,
    super.key,
  });

  final Map<String, dynamic> data;
  final ReceiptChangedCallback? onChanged;
  final bool showErrors;

  @override
  State<PageReceiptTable> createState() => _PageReceiptTableState();
}

class _PageReceiptTableState extends State<PageReceiptTable>
    with _ConnectionReceiptTable {
  @override
  Widget build(BuildContext context) {
    return _ReceiptTableView(
      scalarRows: _scalarRows,
      extras: _extras,
    );
  }
}
