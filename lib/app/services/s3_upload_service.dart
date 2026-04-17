import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/config/api_config.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class S3InitResponse {
  S3InitResponse({
    required this.key,
    required this.presignedUrl,
    required this.headers,
  });
  final String key;
  final String presignedUrl;
  final Map<String, String> headers;

  @override
  String toString() =>
      'S3InitResponse(key: $key, presignedUrl: $presignedUrl, headers: $headers)';
}

class S3UploadService {
  final _api = ApiClient();

  Map<String, dynamic> _normalizeMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  Future<S3InitResponse> initUpload({
    required String contentType,
    required String checksumCRC32,
    required String sha256,
    String? filename,
  }) async {
    final res = await _api.dio.post<Map<String, dynamic>>(
      '/api/file/init',
      data: {
        'contentType': contentType,
        'filename': filename,
        'checksumCRC32': checksumCRC32,
        'sha256': sha256,
      },
    );
    final data = _normalizeMap(res.data);
    final key = data['key']?.toString();
    final presignedUrl = data['presignedUrl']?.toString();
    if (key == null ||
        key.isEmpty ||
        presignedUrl == null ||
        presignedUrl.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Invalid /file/init response: key or presignedUrl is missing',
        type: DioExceptionType.badResponse,
      );
    }
    final headersRaw = data['headers'];
    final headers = headersRaw is Map
        ? headersRaw.map((k, v) => MapEntry(k.toString(), v.toString()))
        : <String, String>{};
    return S3InitResponse(
      key: key,
      presignedUrl: presignedUrl,
      headers: headers,
    );
  }

  /// Like [initUpload] but returns the raw response map so callers can inspect
  /// fields like `status` (e.g. `"duplicate"`) before parsing.
  Future<Map<String, dynamic>> initUploadRaw({
    required String contentType,
    required String checksumCRC32,
    required String sha256,
    String? filename,
  }) async {
    final res = await _api.dio.post<Map<String, dynamic>>(
      '/api/file/init',
      data: {
        'contentType': contentType,
        'filename': filename,
        'checksumCRC32': checksumCRC32,
        'sha256': sha256,
      },
    );
    return _normalizeMap(res.data);
  }

  /// PUT file to S3 using presigned URL (no auth header!)
  Future<void> putToS3({
    required String presignedUrl,
    required File file,
    required Map<String, String> headers,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeoutMs),
      ),
    );

    // Read whole file into memory -> set explicit Content-Length
    final bytes = await file.readAsBytes();

    // Build headers EXACTLY as presigned requires
    final reqHeaders = <String, dynamic>{
      ...headers, // eg. {"Content-Type": "image/jpeg"}
    };

    try {
      final resp = await dio.put<Map<String, dynamic>>(
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

      if (kDebugMode) {
        print('S3 PUT status: ${resp.statusCode}');
        print('S3 PUT headers: ${resp.headers}');
      }

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
      if (kDebugMode) {
        print('DIO S3 ERROR: ${e.message}');

        print('URL: $presignedUrl');

        print('REQ Headers: $reqHeaders');

        print('RESP Status: ${e.response?.statusCode}');

        print('RESP Data: ${e.response?.data}');
      }

      rethrow;
    }
  }

  Future<void> confirmUpload({
    required String key,
    int? size,
    String? mime,
    String? sha256,
  }) async {
    await _api.dio.post<Map<String, dynamic>>(
      '/api/file/confirm',
      data: {
        'key': key,
        if (size != null) 'size': size,
        if (mime != null) 'mime': mime,
        if (sha256 != null) 'sha256': sha256,
      },
    );
  }
}
