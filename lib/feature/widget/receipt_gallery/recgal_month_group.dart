part of '../../page/receipt_gallery_page.dart';

final class _ReceiptMonthGroup {
  _ReceiptMonthGroup({
    required this.label,
    required this.items,
    required this.sortKey,
  });

  final String label;
  final List<ModelReceipt> items;
  final DateTime? sortKey;
}
