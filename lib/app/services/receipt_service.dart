import 'package:fis_app_flutter/core/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Unified service for picking or capturing receipt photos.
class ReceiptService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick from gallery (asks Photos/Storage permission on first use)
  static Future<XFile?> pickFromGallery(BuildContext context) async {
    final ok =
        await PermissionService.ensureFor(ReceiptAction.pick, context: context);
    if (!ok) return null;

    return _picker.pickImage(source: ImageSource.gallery);
  }

  /// Capture with camera (asks Camera permission on first use)
  static Future<XFile?> captureWithCamera(BuildContext context) async {
    final ok = await PermissionService.ensureFor(
      ReceiptAction.capture,
      context: context,
    );
    if (!ok) return null;

    return _picker.pickImage(
      source: ImageSource.camera,
    );
  }
}
