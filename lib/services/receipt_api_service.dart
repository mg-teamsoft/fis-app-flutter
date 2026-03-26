import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fis_app_flutter/feature/model/receipt.dart';
import 'package:fis_app_flutter/feature/model/receipt_detail.dart';
import 'package:fis_app_flutter/services/api_client.dart';

class ReceiptApiService {
  final _api = ApiClient();

  Future<List<ModelReceipt>> listReceipts() async {
    final response = await _api.dio.get('/api/receipts/listReceiptListItems');
    if (response.statusCode == 200) {
      final dynamic body = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      List<dynamic> items;
      if (body is List) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        final dynamic nested =
            body['items'] ?? body['receipts'] ?? body['data'];
        items = (nested is List) ? nested : const [];
      } else {
        items = const [];
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(ModelReceipt.fromJson)
          .toList();
    } else {
      throw Exception('Failed to load receipts');
    }
  }

  Future<ModelReceiptDetail> getReceiptDetail(String id) async {
    final response = await _api.dio.get('/api/receipts/$id');
    if (response.statusCode == 200) {
      return ModelReceiptDetail.fromJson(
        (response.data is String
            ? jsonDecode(response.data as String)
            : response.data) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load receipt detail');
    }
  }

  /// POST /api/receipts — creates a receipt record in MongoDB.
  /// Throws [DioException] on HTTP error so the caller can surface the message.
  Future<Map<String, dynamic>> createReceipt(
      Map<String, dynamic> payload) async {
    final res = await _api.dio.post('/api/receipts', data: payload);
    return res.data as Map<String, dynamic>;
  }
}
