import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:fis_app_flutter/model/receipt_detail.dart';
import 'package:fis_app_flutter/services/excel_service.dart';
import 'package:fis_app_flutter/services/receipt_api_service.dart';
import 'package:fis_app_flutter/services/s3_upload_service.dart';
import 'package:fis_app_flutter/utils/checksum_utils.dart';
import 'package:fis_app_flutter/utils/mime_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

part '../connection/receipt_manuel.dart';
part '../view/receipt_manuel.dart';
part '../widget/receipt_manuel/choice_chip.dart';
part '../widget/receipt_manuel/currency_inpur_formatter.dart';
part '../widget/receipt_manuel/dashboard_painter.dart';
part '../widget/receipt_manuel/datefield_box.dart';
part '../widget/receipt_manuel/dropdown_field_box.dart';
part '../widget/receipt_manuel/field_label.dart';
part '../widget/receipt_manuel/helper_hint.dart';
part '../widget/receipt_manuel/image_picker.dart';
part '../widget/receipt_manuel/invoice_image_picker_box.dart';
part '../widget/receipt_manuel/rest_form.dart';
part '../widget/receipt_manuel/textfield_form.dart';

class PageReceiptManuel extends StatefulWidget {
  const PageReceiptManuel({super.key});

  @override
  State<PageReceiptManuel> createState() => _PageReceiptManuelState();
}

class _PageReceiptManuelState extends State<PageReceiptManuel>
    with _ConnectionReceiptManuel {
  @override
  Widget build(BuildContext context) {
    return _ReceiptManuelView(
      formKey: _formKey,
      receiptNoController: _receiptNoController,
      kdvAmountController: _kdvAmountController,
      totalAmountController: _totalAmountController,
      businessNameController: _businessNameController,
      isUploading: _isUploading,
      pickInvoiceImage: _pickInvoiceImage,
      imageError: _imageError,
      fieldsEnabled: _fieldsEnabled,
      businessNameValidator: _businessNameValidator,
      receiptNoValidator: _receiptNoValidator,
      totalAmountValidator: _totalAmountValidator,
      kdvAmountValidator: _kdvAmountValidator,
      dateText: _dateText,
      pickDate: _pickDate,
      dateError: _dateError,
      selectedCategory: _selectedCategory,
      selectedKdvRate: _selectedKdvRate,
      recalculateKdv: _recalculateKdv,
      paymentType: _paymentType,
      saving: _saving,
      save: _save,
      invoiceImage: _invoiceImage,
      invoiceImageBytes: _invoiceImageBytes,
    );
  }
}
