import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:image_picker/image_picker.dart';

class UploadResult {
  UploadResult({required this.success, required this.message, this.data});
  final bool success;
  final String message;
  final dynamic data;
}

class UploadService {
  final _api = ApiClient();

  /// Upload a single image picked from gallery
  /// Backend: expects field name "files" (array) — adjust if yours is different
  Future<UploadResult> uploadReceiptImage(XFile file) async {
    try {
      final form = FormData.fromMap({
        // if your backend expects multiple: use a list with one entry
        'files': await MultipartFile.fromFile(
          file.path,
          filename: file.name,
          contentType: DioMediaType.parse('image/${_ext(file.path)}'),
        ),
      });

      final res =
          await _api.dio.post<Map<String, dynamic>>('/api/upload', data: form);
      final data = res.data;

      final ok =
          data is Map && (data?['status'] == 'success' || data!['ok'] == true);
      final msg = (data is Map ? (data?['message'] ?? 'Yüklendi') : 'Yüklendi')
          .toString();

      return UploadResult(success: ok, message: msg, data: data);
    } on DioException catch (e) {
      final resposeData = e.response?.data;
      final msg = resposeData is Map<String, dynamic>
          ? (resposeData['message']?.toString() ?? e.message)
          : e.message;
      return UploadResult(success: false, message: msg ?? 'Yükleme hatası');
    } on Exception catch (e) {
      return UploadResult(success: false, message: e.toString());
    }
  }

  String _ext(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'png';
    if (p.endsWith('.webp')) return 'webp';
    if (p.endsWith('.heic') || p.endsWith('.heif')) return 'heic';
    return 'jpeg'; // default
  }
}
