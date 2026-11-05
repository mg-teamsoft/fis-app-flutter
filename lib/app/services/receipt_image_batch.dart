import 'package:fis_app_flutter/app/services/receipt_image_service.dart';
import 'package:image_picker/image_picker.dart';

/// Owns only generated files. Source gallery/camera files are never deleted.
class ReceiptImageBatch {
  ReceiptImageBatch({
    Future<XFile> Function(XFile)? prepare,
    Future<void> Function(XFile)? delete,
  })  : _prepare = prepare ?? ReceiptImageService.prepare,
        _delete = delete ?? ReceiptImageService.deletePrepared;

  final Future<XFile> Function(XFile) _prepare;
  final Future<void> Function(XFile) _delete;
  final List<XFile> _prepared = [];

  Future<List<XFile>> prepareAll(
    List<XFile> sources, {
    required void Function(int completed, int total) onProgress,
    required bool Function() isCancelled,
  }) async {
    try {
      onProgress(0, sources.length);
      for (final source in sources) {
        if (isCancelled()) throw Exception('Görsel hazırlama iptal edildi.');
        // Intentionally await each image: never decode a whole batch at once.
        try {
          _prepared.add(await _prepare(source));
        } on Exception catch (e) {
          throw Exception(
            '${_prepared.length + 1}/${sources.length} görsel (${source.name}) hazırlanamadı: $e',
          );
        }
        if (isCancelled()) throw Exception('Görsel hazırlama iptal edildi.');
        onProgress(_prepared.length, sources.length);
      }
      return List<XFile>.unmodifiable(_prepared);
    } on Exception {
      await dispose();
      rethrow;
    }
  }

  Future<void> dispose() async {
    for (final file in _prepared) {
      await _delete(file);
    }
    _prepared.clear();
  }
}
