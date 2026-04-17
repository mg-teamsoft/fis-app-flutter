import 'dart:convert';

import 'package:fis_app_flutter/model/receipt_summary.dart';

class HomeSummary {
  HomeSummary({
    required this.totalSpent,
    required this.monthlyLimitAmount,
    required this.limitUsageText,
    required this.recentReceipts,
  });
  factory HomeSummary.fromResponse(dynamic data) {
    final Map<String, dynamic> json;
    if (data is String) {
      final decoded = jsonDecode(data);
      json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } else if (data is Map<String, dynamic>) {
      json = data;
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
            .map(ReceiptSummary.fromJson)
            .toList()
        : <ReceiptSummary>[];

    return HomeSummary(
      totalSpent: parseNumber(json['totalSpent']),
      monthlyLimitAmount: parseNumber(json['monthlyLimitAmount']),
      limitUsageText: json['limitUsageText']?.toString() ?? '',
      recentReceipts: recentReceipts,
    );
  }

  final double totalSpent;
  final double monthlyLimitAmount;
  final String limitUsageText;
  final List<ReceiptSummary> recentReceipts;
}
