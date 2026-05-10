import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';

class ExcelService {
  final _api = ApiClient();
  String? _lastWriteMessage;

  String? get lastWriteMessage => _lastWriteMessage;

  Future<bool> pushReceipt(String key, Map<String, dynamic> receiptJson) async {
    try {
      _lastWriteMessage = null;
      final payload = <String, dynamic>{
        'key': key,
        'receiptJson': receiptJson,
      };
      final res = await _api.dio
          .post<Map<String, dynamic>>('/api/excel/write', data: payload);
      final data = res.data ?? const <String, dynamic>{};
      final message = data['message']?.toString().trim();
      _lastWriteMessage =
          message != null && message.isNotEmpty ? message : null;
      final ok = data['status'] == 'success';
      return ok;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          _lastWriteMessage = message;
          return false;
        }
      }
      _lastWriteMessage = 'Failed to push receipt to Excel: ${e.message}';
      return false;
    } on Exception catch (e) {
      _lastWriteMessage = 'Unexpected error: $e';
      return false;
    }
  }

  /// GET /excel/files  -> list the single file record (one per user)
  Future<List<Map<String, dynamic>>> listFiles({String? customerUserId}) async {
    try {
      final normalizedCustomerUserId = customerUserId?.trim();
      final res =
          normalizedCustomerUserId == null || normalizedCustomerUserId.isEmpty
              ? await _api.dio.get<Map<String, dynamic>>('/api/excel/files')
              : await _api.dio.post<Map<String, dynamic>>(
                  '/api/supervisor/customers/excel/files',
                  data: {'customerUserId': normalizedCustomerUserId},
                );
      final list =
          (res.data!['files'] as List?)?.cast<Map<String, dynamic>>() ??
              const [];
      return list;
    } on DioException catch (e) {
      throw Exception('Failed to list Excel files: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // User: GET /excel/files/:id/presign
  // Supervisor: POST /supervisor/customers/excel/files/:id/presign
  Future<String> presignGet(String idOrKey, {String? customerUserId}) async {
    try {
      final normalizedCustomerUserId = customerUserId?.trim();
      final res =
          normalizedCustomerUserId == null || normalizedCustomerUserId.isEmpty
              ? await _api.dio.get<Map<String, dynamic>>(
                  '/api/excel/files/$idOrKey/presign',
                )
              : await _api.dio.post<Map<String, dynamic>>(
                  '/api/supervisor/customers/excel/files/$idOrKey/presign',
                  data: {'customerUserId': normalizedCustomerUserId},
                );
      return res.data!['url'] as String;
    } on DioException catch (e) {
      throw Exception('Failed to get presigned URL: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
