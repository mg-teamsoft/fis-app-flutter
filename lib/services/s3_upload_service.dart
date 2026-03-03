import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class S3InitResponse {
  final String key;
  final String presignedUrl;
  final Map<String, String> headers;

  S3InitResponse(
      {required this.key, required this.presignedUrl, required this.headers});

  @override
  String toString() =>
      'S3InitResponse(key: $key, presignedUrl: $presignedUrl, headers: $headers)';
}

class S3UploadService {
  final _api = ApiClient();

  Future<S3InitResponse> initUpload({
    required String contentType,
    String? filename,
    required String checksumCRC32,
    required String sha256,
  }) async {
    final res = await _api.dio.post('/api/file/init', data: {
      'contentType': contentType,
      'filename': filename,
      'checksumCRC32': checksumCRC32,
      'sha256': sha256,
    });
    final data = res.data as Map<String, dynamic>;
    return S3InitResponse(
      key: data['key'] as String,
      presignedUrl: data['presignedUrl'] as String,
      headers: (data['headers'] as Map)
          .map((k, v) => MapEntry(k.toString(), v.toString())),
    );
  }

  /// Like [initUpload] but returns the raw response map so callers can inspect
  /// fields like `status` (e.g. `"duplicate"`) before parsing.
  Future<Map<String, dynamic>> initUploadRaw({
    required String contentType,
    String? filename,
    required String checksumCRC32,
    required String sha256,
  }) async {
    final res = await _api.dio.post('/api/file/init', data: {
      'contentType': contentType,
      'filename': filename,
      'checksumCRC32': checksumCRC32,
      'sha256': sha256,
    });
    return res.data as Map<String, dynamic>;
  }

  /// PUT file to S3 using presigned URL (no auth header!)
  Future<void> putToS3({
    required String presignedUrl,
    required File file,
    required Map<String, String> headers,
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeoutMs),
    ));

    // Read whole file into memory -> set explicit Content-Length
    final bytes = await file.readAsBytes();

    // Build headers EXACTLY as presigned requires
    final reqHeaders = <String, dynamic>{
      ...headers, // eg. {"Content-Type": "image/jpeg"}
    };

    try {
      final resp = await dio.put(
        presignedUrl,
        data: bytes,
        options: Options(
          headers: reqHeaders,
          // allow 2xx-4xx to bubble with body so we can log error payload
          validateStatus: (code) => code != null && code < 600,
        ),
      );

      // Strong logging
      // (remove in prod)
      // ignore: avoid_print
      print('S3 PUT status: ${resp.statusCode}');
      // ignore: avoid_print
      print('S3 PUT headers: ${resp.headers}');
      if (resp.statusCode != 200) {
        // Some regions return 200 OK, some 204 No Content – both OK
        if (resp.statusCode != 204) {
          throw DioException(
            requestOptions: resp.requestOptions,
            response: resp,
            message:
                'S3 upload failed: HTTP ${resp.statusCode} ${resp.statusMessage}',
            type: DioExceptionType.badResponse,
          );
        }
      }
    } on DioException catch (e) {
      // ignore: avoid_print
      print('DIO S3 ERROR: ${e.message}');
      // ignore: avoid_print
      print('URL: $presignedUrl');
      // ignore: avoid_print
      print('REQ Headers: $reqHeaders');
      // ignore: avoid_print
      print('RESP Status: ${e.response?.statusCode}');
      // ignore: avoid_print
      print('RESP Data: ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> confirmUpload({
    required String key,
    int? size,
    String? mime,
    String? sha256,
  }) async {
    await _api.dio.post('/api/file/confirm', data: {
      'key': key,
      if (size != null) 'size': size,
      if (mime != null) 'mime': mime,
      if (sha256 != null) 'sha256': sha256,
    });
  }
}
