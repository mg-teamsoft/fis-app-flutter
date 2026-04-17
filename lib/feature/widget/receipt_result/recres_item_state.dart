part of '../../page/receipt_result_page.dart';

class _ItemState {
  _ItemState({required this.item});
  final SelectedItem item;
  PhotoViewController? photoController;
  double rotationDeg = 0;

  String status = StatusType.processing.name;
  bool? selected;
  bool showErrors = false;
  int countdown = 10;
  bool active = true;
  String? lastError;
  Map<String, dynamic>? rawReceipt;
  Map<String, dynamic>? receipt;
  TextEditingController? controller;
}
