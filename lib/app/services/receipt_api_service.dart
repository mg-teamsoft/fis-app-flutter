import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/feature/model/receipt_detail_model.dart';
import 'package:fis_app_flutter/feature/model/receipt_model.dart';

class ReceiptApiService {
  final _api = ApiClient();

  Future<List<ModelReceipt>> listReceipts({String? customerId}) async {
    final normalizedCustomerId = customerId?.trim();
    final response =
        normalizedCustomerId == null || normalizedCustomerId.isEmpty
            ? await _api.dio.get<dynamic>('/api/receipts/listReceiptListItems')
            : await _api.dio.post<dynamic>(
                '/api/supervisor/customers/receipts',
                data: {'customerUserId': normalizedCustomerId},
              );

    return _mapReceiptListResponse(response);
  }

  List<ModelReceipt> _mapReceiptListResponse(Response<dynamic> response) {
    if (response.statusCode == 200) {
      final dynamic body = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      final List<dynamic> items;
      if (body is List) {
        items = body;
      } else if (body is Map) {
        final dynamic nested =
            body['items'] ?? body['receipts'] ?? body['data'];
        items = (nested is List) ? nested : const [];
      } else {
        items = const [];
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => ModelReceipt.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('Fiş listesi yüklenemedi (${response.statusCode})');
  }

  Future<ModelReceiptDetail> getReceiptDetail(
    String id, {
    String? customerUserId,
  }) async {
    final normalizedCustomerUserId = customerUserId?.trim();
    final response =
        normalizedCustomerUserId == null || normalizedCustomerUserId.isEmpty
            ? await _api.dio.get<dynamic>('/api/receipts/$id')
            : await _api.dio.post<dynamic>(
                '/api/supervisor/customers/receipts/$id',
                data: {'customerUserId': normalizedCustomerUserId},
              );

    if (response.statusCode == 200) {
      final dynamic body = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      final Map<String, dynamic> jsonMap;
      if (body is List && body.isNotEmpty) {
        jsonMap = Map<String, dynamic>.from(body.first as Map);
      } else if (body is Map) {
        jsonMap = Map<String, dynamic>.from(body);
      } else {
        throw Exception('Geçersiz fiş detay verisi');
      }

      return ModelReceiptDetail.fromJson(jsonMap);
    } else {
      throw Exception('Fiş detayı yüklenemedi (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> createReceipt(
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.dio.post<dynamic>('/api/receipts', data: payload);

    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    return <String, dynamic>{};
  }
}
