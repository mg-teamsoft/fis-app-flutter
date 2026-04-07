import 'dart:convert';

import 'package:fis_app_flutter/feature/model/receipt_model.dart';

final class ModelHome {
  ModelHome({
    required this.totalSpent,
    required this.monthlyLimitAmount,
    required this.limitUsageText,
    required this.recentReceipts,
  });

  factory ModelHome.fromResponse(dynamic data) {
    final Map<String, dynamic> json;

    if (data is Map<String, dynamic>) {
      json = data;
    } else if (data is List && data.isNotEmpty) {
      final first = data.first;
      json = first is Map<String, dynamic> ? first : <String, dynamic>{};
    } else if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        json = first is Map<String, dynamic> ? first : <String, dynamic>{};
      } else {
        json = <String, dynamic>{};
      }
    } else {
      json = <String, dynamic>{};
    }

    double parseNumber(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
      return 0;
    }

    final receiptsJson = json['recentReceipts'];
    final recentReceipts = (receiptsJson is List)
        ? receiptsJson
            .whereType<Map<String, dynamic>>()
            .map(ModelReceipt.fromJson)
            .toList()
        : <ModelReceipt>[];

    return ModelHome(
      totalSpent: parseNumber(json['totalSpent']),
      monthlyLimitAmount: parseNumber(json['monthlyLimitAmount']),
      limitUsageText: json['limitUsageText']?.toString() ?? '',
      recentReceipts: recentReceipts,
    );
  }

  final double totalSpent;
  final double monthlyLimitAmount;
  final String limitUsageText;
  final List<ModelReceipt> recentReceipts;
}
