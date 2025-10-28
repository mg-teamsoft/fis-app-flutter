import 'dart:convert';
import 'package:fis_app_flutter/models/receipt_detail.dart';
import 'package:fis_app_flutter/models/receipt_summary.dart';
import 'package:fis_app_flutter/services/api_client.dart';

class ReceiptApiService {
  final _api = ApiClient();

  Future<List<ReceiptSummary>> listReceipts() async {
    final response = await _api.dio.get('/api/receipts/listReceiptListItems');
    if (response.statusCode == 200) {
      final dynamic body =
          response.data is String ? jsonDecode(response.data) : response.data;

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
          .map(ReceiptSummary.fromJson)
          .toList();
    } else {
      throw Exception('Failed to load receipts');
    }
  }

  Future<ReceiptDetail> getReceiptDetail(String id) async {
    final response = await _api.dio.get('/api/receipts/$id');
    if (response.statusCode == 200) {
      return ReceiptDetail.fromJson(
          response.data is String ? jsonDecode(response.data) : response.data);
    } else {
      throw Exception('Failed to load receipt detail');
    }
  }
}
