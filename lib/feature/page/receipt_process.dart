import 'dart:io' show File;

import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/job_service.dart';
import 'package:fis_app_flutter/app/services/s3_upload_service.dart';
import 'package:fis_app_flutter/app/utils/checksum_utils.dart';
import 'package:fis_app_flutter/app/utils/mime_utils.dart';
import 'package:fis_app_flutter/core/crypto_sha.dart';
import 'package:fis_app_flutter/model/receipt_flow_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

part '../controller/receipt_proccess.dart';
part '../view/receipt_process.dart';
part '../widget/receipt_process/filled_button.dart';
part '../widget/receipt_process/list.dart';

class PageReceiptProcess extends StatefulWidget {
  const PageReceiptProcess({required this.files, super.key});
  final List<XFile> files;

  @override
  State<PageReceiptProcess> createState() => _PageReceiptProcess();
}

class _PageReceiptProcess extends State<PageReceiptProcess>
    with _ConnectionReceiptProcess {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ReceiptProcessView(
        size: _size,
        files: widget.files,
        processing: _processing,
        bytesCache: _bytesCache,
        process: _process,
      ),
    );
  }
}
