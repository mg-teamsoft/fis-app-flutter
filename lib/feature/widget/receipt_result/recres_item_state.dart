part of '../../page/receipt_result_page.dart';

class _ItemState {
  _ItemState({required this.item});
  final SelectedItem item;
  PhotoViewController? photoController;
  double rotationDeg = 0;

  String status = StatusType.processing.name;
  // null means unknown/unchecked, never a successful verification.
  bool? needsReview;

  String? get reviewNotice {
    if (status != StatusType.done.name) return null;
    return switch (needsReview) {
      true => 'Fiş bilgilerini kontrol edin',
      false => null,
      null => 'Doğrulama durumu bilinmiyor. Fiş bilgilerini kontrol edin.',
    };
  }

  bool? selected;
  bool showErrors = false;
  int countdown = 10;
  bool active = true;
  String? lastError;
  Map<String, dynamic>? rawReceipt;
  Map<String, dynamic>? receipt;
  TextEditingController? controller;
}
