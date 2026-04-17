enum ReceiptCategory {
  food('YİYECEK'),
  meal('YEMEK'),
  fuel('AKARYAKIT'),
  parking('OTOPARK'),
  electronic('ELEKTRONİK'),
  medication('İLAÇ'),
  stationery('KIRTASİYE'),
  personalCare('KİŞİSEL BAKIM');

  const ReceiptCategory(this.label);
  final String label;
}

class ReceiptDetail {
  ReceiptDetail({
    required this.businessName,
    required this.receiptNumber,
    required this.totalAmount,
    required this.vatAmount,
    required this.vatRate,
    required this.transactionDate,
    required this.transactionType,
    required this.paymentType,
    required this.imageUrl,
  });
  factory ReceiptDetail.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0;
    }

    return ReceiptDetail(
      businessName:
          (json['businessName'] ?? json['companyName'] ?? '').toString(),
      receiptNumber: (json['receiptNumber'] ?? '').toString(),
      totalAmount: parseDouble(json['totalAmount']),
      vatAmount: parseDouble(json['vatAmount']),
      vatRate: parseDouble(json['vatRate']),
      transactionDate: parseDate(json['transactionDate']),
      transactionType: json['transactionType']?.toString(),
      paymentType: json['paymentType']?.toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }
  final String businessName;
  final String receiptNumber;
  final double totalAmount;
  final double vatAmount;
  final double vatRate;
  final DateTime? transactionDate;
  final String? transactionType;
  final String? paymentType;
  final String imageUrl;
}
