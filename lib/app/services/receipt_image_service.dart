import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Prepares the actual upload bytes locally, before any backend request.
class ReceiptImageService {
  static const _cropChannel = MethodChannel('fis_app/receipt_crop');

  static Future<XFile> prepare(XFile source) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      throw Exception(
        'Otomatik fatura kırpma yalnızca Android ve iOS üzerinde destekleniyor.',
      );
    }
    Uint8List? cropped;
    try {
      cropped = await _cropChannel.invokeMethod<Uint8List>(
        'cropDocument',
        {'path': source.path},
      );
    } on PlatformException {
      throw Exception(
        'Fatura kırpılamadı. Belgenin tamamı görünecek şekilde tekrar fotoğraf çekin.',
      );
    }
    // No detected rectangle is a valid outcome on patterned backgrounds.
    // Preserve the full photo and still apply the upload size/quality limits.
    final input = cropped == null || cropped.isEmpty
        ? await source.readAsBytes()
        : cropped;
    final codec = await ui.instantiateImageCodec(input);
    late int width;
    late int height;
    try {
      final frame = await codec.getNextFrame();
      width = frame.image.width;
      height = frame.image.height;
      frame.image.dispose();
    } finally {
      codec.dispose();
    }

    // Limit the longest edge to 2560 without enlarging the cropped image.
    // Both target dimensions must share the same scale: the compressor's
    // minWidth/minHeight parameters alone do not impose a bounding box.
    final scale = math.min(1, 2560 / math.max(width, height));
    late Uint8List bytes;
    try {
      bytes = await FlutterImageCompress.compressWithList(
        input,
        minWidth: math.max(1, (width * scale).floor()),
        minHeight: math.max(1, (height * scale).floor()),
        quality: 88,
        // Keep the upload format explicit alongside its MIME validation.
        // ignore: avoid_redundant_argument_values
        format: CompressFormat.jpeg,
      );
      // The plugin reports unsupported output formats as UnsupportedError.
      // ignore: avoid_catching_errors
    } on UnsupportedError {
      throw Exception('Bu cihazda JPEG dönüştürme desteklenmiyor.');
    }
    // Reject invalid output before creating upload metadata or checksums.
    if (bytes.length < 3 ||
        bytes[0] != 0xff ||
        bytes[1] != 0xd8 ||
        bytes[2] != 0xff) {
      throw Exception('Bu cihazda görsel JPEG formatına dönüştürülemedi.');
    }
    final name = '${p.basenameWithoutExtension(source.name)}.jpg';
    final result = XFile.fromData(bytes, name: name, mimeType: 'image/jpeg');
    if (kIsWeb) return result;

    final directory = await _outputDirectory();
    final output = p.join(
      directory.path,
      'receipt_${DateTime.now().microsecondsSinceEpoch}_$name',
    );
    await result.saveTo(output);
    return XFile(output, name: name, mimeType: 'image/jpeg');
  }

  static Future<Directory> _outputDirectory() async {
    final temporary = await getTemporaryDirectory();
    return Directory(p.join(temporary.path, 'receipt_images'))
        .create(recursive: true);
  }

  static Future<void> deletePrepared(XFile file) async {
    if (kIsWeb) return;
    try {
      final directory = await _outputDirectory();
      // Only this service's output directory can be cleaned, never a source.
      if (p.dirname(p.normalize(file.path)) != p.normalize(directory.path)) {
        return;
      }
      final output = File(file.path);
      if (output.statSync().type == FileSystemEntityType.file) {
        await output.delete();
      }
    } on FileSystemException catch (e) {
      debugPrint('Receipt temporary image cleanup failed: $e');
    }
  }

  static Future<void> cleanExpired() async {
    if (kIsWeb) return;
    try {
      final directory = await _outputDirectory();
      final cutoff = DateTime.now().subtract(const Duration(days: 1));
      await for (final entry in directory.list(followLinks: false)) {
        if (entry is File && entry.statSync().modified.isBefore(cutoff)) {
          await entry.delete();
        }
      }
    } on FileSystemException catch (e) {
      debugPrint('Expired receipt image cleanup failed: $e');
    }
  }
}
