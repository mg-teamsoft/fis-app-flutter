final class ModelReceipt {
  ModelReceipt({
    required this.id,
    required this.businessName,
    required this.receiptNumber,
    required this.totalAmount,
    required this.transactionDate,
    this.status,
  });

  factory ModelReceipt.fromJson(Map<String, dynamic> json) {
    final rawDate = json['transactionDate'];
    DateTime? parsedDate;
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    }

    final dynamic totalAmountValue = json['totalAmount'];
    final amount = totalAmountValue is num
        ? totalAmountValue.toDouble()
        : double.tryParse(totalAmountValue?.toString() ?? '') ?? 0.0;

    final dynamic idValue = json['_id'] ?? json['id'];
    return ModelReceipt(
      id: idValue?.toString() ?? '',
      businessName: json['businessName']?.toString() ?? '',
      receiptNumber: json['receiptNumber']?.toString() ?? '',
      totalAmount: amount,
      transactionDate: parsedDate,
      status: json['status']?.toString(),
    );
  }
  final String id;
  final String businessName;
  final String receiptNumber;
  final double totalAmount;
  final DateTime? transactionDate;
  final String? status;
}
