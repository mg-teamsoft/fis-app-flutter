part of '../../../page/receipt_gallery.dart';

class _ReceiptGalleryMonthGroup {

   const _ReceiptGalleryMonthGroup({
    required this.label,
    required this.items,
    required this.sortKey,
  });

  final String label;
  final List<ReceiptSummary> items;
  final DateTime? sortKey;

}