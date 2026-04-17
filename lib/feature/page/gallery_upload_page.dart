import 'dart:io';
import 'dart:typed_data';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/receipt_service.dart';
import 'package:fis_app_flutter/app/services/upload_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

part '../controller/gallery_upload_controller.dart';
part '../view/gallery_upload_view.dart';
part '../widget/gallery_upload/galup_filled_button.dart';
part '../widget/gallery_upload/galup_image_area.dart';
part '../widget/gallery_upload/galup_upload_button.dart';

final class PageGalleryUpload extends StatefulWidget {
  const PageGalleryUpload({super.key});

  @override
  State<PageGalleryUpload> createState() => _PageGalleryUploadState();
}

final class _PageGalleryUploadState extends State<PageGalleryUpload>
    with _ConnectionGalleryUpload {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeriden Yükle')),
      body: _GalleryUploadView(
        picked: _picked,
        uploading: _uploading,
        img: _img,
        pick: _pick,
        upload: _upload,
      ),
    );
  }
}
