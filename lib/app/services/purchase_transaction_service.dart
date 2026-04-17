import 'dart:convert';

import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/model/purchase_transaction.dart';

class PurchaseTransactionService {
  PurchaseTransactionService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<PurchaseTransaction>> listTransactions() async {
    final response = await _api.dio.get<dynamic>('/api/purchases/transactions');

    final statusCode = response.statusCode;
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      final dynamic body = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      final items = _extractTransactionList(body);

      return items
          .whereType<Map<String, dynamic>>()
          .map(
            (item) =>
                PurchaseTransaction.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    throw Exception(
      'Ödeme işlemleri alınamadı (Kod: ${statusCode ?? 'unknown'})',
    );
  }

  List<dynamic> _extractTransactionList(dynamic body) {
    if (body == null) return const [];

    if (body is List) return body;

    if (body is Map) {
      final map = Map<String, dynamic>.from(body);

      final dynamic candidates =
          map['transactions'] ?? map['items'] ?? map['data'];

      if (candidates is List) return candidates;

      if (candidates is Map) {
        final nestedMap = Map<String, dynamic>.from(candidates);
        final dynamic nestedCandidates = nestedMap['transactions'] ??
            nestedMap['items'] ??
            nestedMap['data'];

        if (nestedCandidates is List) return nestedCandidates;
      }
    }

    return const [];
  }
}
