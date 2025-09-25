import 'package:dio/dio.dart';
import 'api_client.dart';

class ExcelService {
  final _api = ApiClient();

  Future<bool> pushReceipt(Map<String, dynamic> receiptJson) async {
    try {
      final res = await _api.dio.post('/excel/write', data: receiptJson);
      final data = res.data as Map<String, dynamic>;
      return data['status'] == 'success';
    } on DioException catch (e) {
      throw Exception('Failed to push receipt to Excel: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// GET /excel/files  -> list the single file record (one per user)
  Future<List<Map<String, dynamic>>> listFiles() async {
    try {
      final res = await _api.dio.get('/excel/files');
      final list = (res.data['files'] as List?)?.cast<Map<String, dynamic>>() ??
          const [];
      return list;
    } on DioException catch (e) {
      throw Exception('Failed to list Excel files: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // GET /excel/files/:id/presign -> {url, file}
  Future<String> presignGet(String idOrKey) async {
    try {
      final res = await _api.dio.get('/excel/files/$idOrKey/presign');
      return res.data['url'] as String;
    } on DioException catch (e) {
      throw Exception('Failed to get presigned URL: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
