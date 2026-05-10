import 'dart:async';

import 'package:fis_app_flutter/app/config/contact_permission.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/customer_service.dart';
import 'package:fis_app_flutter/app/services/excel_service.dart';
import 'package:fis_app_flutter/app/services/file_download_service.dart';
import 'package:fis_app_flutter/model/excel_file_entry.dart';
import 'package:fis_app_flutter/model/status_type.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

part '../controller/excel_controller.dart';
part '../view/excel_view.dart';
part '../widget/excel/ex_builder.dart';
part '../widget/excel/ex_customer_picker.dart';
part '../widget/excel/ex_data_table.dart';
part '../widget/excel/ex_twice_button.dart';

class PageExcel extends StatefulWidget {
  const PageExcel({this.initialEntries, this.initialCustomerId, super.key});

  final List<ExcelFileEntry>? initialEntries;
  final String? initialCustomerId;

  @override
  State<PageExcel> createState() => _PageExcelState();
}

class _PageExcelState extends State<PageExcel> with _ConnectionExcel {
  @override
  Widget build(BuildContext context) {
    return _ExcelView(
      scrollController: _scrollController,
      busy: _busy,
      open: _open,
      download: _download,
      future: _future,
      customerItems: _customerItems,
      selectedCustomerId: _selectedCustomerId,
      appliedCustomerId: _appliedCustomerId,
      isLoadingCustomers: _isLoadingCustomers,
      onCustomerChanged: _onCustomerChanged,
      applyCustomerSelection: _applyCustomerSelection,
    );
  }
}
