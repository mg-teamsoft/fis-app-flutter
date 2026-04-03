import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io' show File;
import 'dart:math' as math;

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/excel_service.dart';
import 'package:fis_app_flutter/app/services/job_service.dart';
import 'package:fis_app_flutter/feature/page/receipt_table.dart';
import 'package:fis_app_flutter/model/receipt_flow_models.dart';
import 'package:fis_app_flutter/model/status_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';

part '../controller/receipt_result.dart';
part '../view/receipt_result.dart';
part '../widget/receipt_result/appbar.dart';
part '../widget/receipt_result/button_area.dart';
part '../widget/receipt_result/changed_callback.dart';
part '../widget/receipt_result/cliprect.dart';
part '../widget/receipt_result/editor_area.dart';
part '../widget/receipt_result/item_state.dart';
part '../widget/receipt_result/listview_returner.dart';

class PageReceiptResult extends StatefulWidget {
  const PageReceiptResult({required this.items, super.key});

  final List<SelectedItem> items;

  @override
  State<PageReceiptResult> createState() => _PageReceiptResultState();
}

class _PageReceiptResultState extends State<PageReceiptResult>
    with _ConnectionReceiptResult {
  @override
  Widget build(BuildContext context) {
    return _ReceiptResultView(
      rotateImage: _rotateImage,
      removeItem: _removeItem,
      approveAll: _approveAll,
      jobs: _jobs,
      excel: _excel,
      submitting: _submitting,
      hasSuccessfulSubmission: _hasSuccessfulSubmission,
      state: _state,
      tick: _tick,
      startTicker: _startTicker,
      pollOne: _pollOne,
      errors: _ConnectionReceiptResult._collectErrors,
      showOnlySelected: _showOnlySelected,
      bytesCache: _bytesCache,
      itemList: _items,
    );
  }
}
