class PurchaseTransaction {
  PurchaseTransaction({
    required this.transactionId,
    required this.originalTransactionId,
    required this.purchaseDate,
    required this.expiresDate,
    required this.platform,
    required this.productType,
    required this.productId,
  });
  factory PurchaseTransaction.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    DateTime? readDate(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is DateTime) return value;
        if (value is int) {
          final millis = value > 1000000000000 ? value : value * 1000;
          return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true)
              .toLocal();
        }
        if (value is double) {
          final intVal = value.toInt();
          final millis = intVal > 1000000000000 ? intVal : intVal * 1000;
          return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true)
              .toLocal();
        }
        if (value is Map && value.containsKey(r'$date')) {
          final parsed = DateTime.tryParse(value[r'$date'].toString());
          if (parsed != null) return parsed.toLocal();
        }
        final parsed = DateTime.tryParse(value.toString());
        if (parsed != null) return parsed.toLocal();
      }
      return null;
    }

    return PurchaseTransaction(
      transactionId: readString(
        const ['transactionId', 'transaction_id', 'id'],
      ),
      originalTransactionId: readString(
        const [
          'originalTransactionId',
          'original_transaction_id',
          'originalTransactionID',
        ],
      ),
      purchaseDate: readDate(
        const ['purchaseDate', 'purchase_date', 'purchasedAt', 'createdAt'],
      ),
      expiresDate: readDate(
        const ['expiresDate', 'expires_date', 'expirationDate', 'expiryDate'],
      ),
      platform: readString(
        const ['platform'],
      ),
      productType: readString(
        const ['productType', 'product_type'],
      ),
      productId: readString(
        const ['productId', 'product_id'],
      ),
    );
  }

  final String transactionId;
  final String originalTransactionId;
  final DateTime? purchaseDate;
  final DateTime? expiresDate;
  final String platform;
  final String productType;
  final String productId;
}
