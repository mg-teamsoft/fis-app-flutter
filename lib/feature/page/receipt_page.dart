import 'dart:async';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/receipt_image_batch.dart';
import 'package:fis_app_flutter/app/services/receipt_image_service.dart';
import 'package:fis_app_flutter/app/services/receipt_service.dart';
import 'package:fis_app_flutter/app/widget/build_action.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

part '../controller/receipt_controller.dart';
part '../view/receipt_view.dart';
part '../widget/receipt/rec_bottom_head.dart';
part '../widget/receipt/rec_mid_head.dart';
part '../widget/receipt/rec_photo_tips.dart';
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
    return PopScope(
      canPop: !_preparing,
      child: Scaffold(
        body: Stack(
          children: [
            AbsorbPointer(
              absorbing: _preparing,
              child: _ReceiptView(
                size: _size,
                pickMultiGallery: _pickMultiGallery,
                captureCamera: _captureCamera,
                openManualForm: _openManualForm,
                processSelected: _processSelected,
                picked: _picked,
                removeSelected: _removeSelected,
                bytesCache: _bytesCache,
                processButtonLabel: _processButtonLabel,
              ),
            ),
            if (_preparing)
              Positioned.fill(
                child: ColoredBox(
                  color: context.colorScheme.surface.withValues(alpha: 0.95),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Görseller hazırlanıyor'),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: _picked.isEmpty
                                ? 0
                                : _preparedCount / _picked.length,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$_preparedCount/${_picked.length} görsel hazırlandı',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
