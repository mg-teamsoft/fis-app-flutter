import 'dart:convert';

import '../models/purchase_transaction.dart';
import 'api_client.dart';

class PurchaseTransactionService {
  PurchaseTransactionService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<PurchaseTransaction>> listTransactions() async {
    final response = await _api.dio.get('/api/purchases/transactions');
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final dynamic body =
          response.data is String ? jsonDecode(response.data) : response.data;
      final items = _extractTransactionList(body);
      return items
          .whereType<Map>()
          .map((item) =>
              PurchaseTransaction.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    throw Exception(
      'Ödeme işlemleri alınamadı (${response.statusCode ?? 'unknown'})',
    );
  }

  List<dynamic> _extractTransactionList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final direct = body['transactions'] ?? body['items'] ?? body['data'];
      if (direct is List) return direct;
      if (direct is Map<String, dynamic>) {
        final nested =
            direct['transactions'] ?? direct['items'] ?? direct['data'];
        if (nested is List) return nested;
      }
    }
    return const [];
  }
}
