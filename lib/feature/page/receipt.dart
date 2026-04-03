import 'dart:io' show File;
import 'dart:typed_data';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/receipt_service.dart';
import 'package:fis_app_flutter/app/widget/build_action.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

part '../controller/receipt.dart';
part '../view/receipt.dart';
part '../widget/receipt/bottom_head.dart';
part '../widget/receipt/mid_head.dart';
part '../widget/receipt/top_head.dart';

class PageReceipt extends StatefulWidget {
  const PageReceipt({super.key});

  @override
  State<PageReceipt> createState() => _PageReceiptState();
}

class _PageReceiptState extends State<PageReceipt>
    with _ConnectionReceiptInitial {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ReceiptView(
        size: _size,
        pickMultiGallery: _pickMultiGallery,
        captureCamera: _captureCamera,
        openManualForm: _openManualForm,
        processSelected: _processSelected,
        picked: _picked,
        bytesCache: _bytesCache,
        processButtonLabel: _processButtonLabel,
      ),
    );
  }
}
