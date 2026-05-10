part of '../page/receipt_manuel_page.dart';

class _ReceiptManuelView extends StatelessWidget {
  const _ReceiptManuelView({
    required this.paymentType,
    required this.saving,
    required this.save,
    required this.formKey,
    required this.receiptNoController,
    required this.kdvAmountController,
    required this.totalAmountController,
    required this.businessNameController,
    required this.isUploading,
    required this.pickInvoiceImage,
    required this.imageError,
    required this.fieldsEnabled,
    required this.businessNameValidator,
    required this.receiptNoValidator,
    required this.totalAmountValidator,
    required this.kdvAmountValidator,
    required this.dateText,
    required this.pickDate,
    required this.dateError,
    required this.onCategoryChanged,
    required this.onKdvRateChanged,
    required this.onPaymentTypeChanged,
    this.selectedCategory,
    this.selectedKdvRate,
    this.invoiceImage,
    this.invoiceImageBytes,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController receiptNoController;
  final TextEditingController kdvAmountController;
  final TextEditingController totalAmountController;
  final TextEditingController businessNameController;
  final XFile? invoiceImage;
  final Uint8List? invoiceImageBytes;
  final bool isUploading;
  final Future<void> Function() pickInvoiceImage;
  final bool imageError;
  final bool fieldsEnabled;

  final String? Function(String?) businessNameValidator;
  final String? Function(String?) receiptNoValidator;
  final String? Function(String?) totalAmountValidator;
  final String? Function(String?) kdvAmountValidator;
  final String dateText;
  final Future<void> Function() pickDate;
  final bool dateError;
  final ReceiptCategory? selectedCategory;
  final String? selectedKdvRate;
  final void Function(ReceiptCategory?) onCategoryChanged;
  final void Function(String?) onKdvRateChanged;
  final void Function(String) onPaymentTypeChanged;
  final String paymentType;
  final bool saving;
  final Future<void> Function() save;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const ThemePadding.horizontalSymmetric(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReceiptManuelImagePicker(
              invoiceImage: invoiceImage,
              invoiceImageBytes: invoiceImageBytes,
              isUploading: isUploading,
              imageError: imageError,
              pickInvoiceImage: pickInvoiceImage,
            ),
            _ReceiptManuelHelperHint(
              fieldsEnabled: fieldsEnabled,
              isUploading: isUploading,
            ),
            _ReceiptManuelRestForm(
              businessNameController: businessNameController,
              receiptNoController: receiptNoController,
              kdvAmountController: kdvAmountController,
              totalAmountController: totalAmountController,
              isUploading: isUploading,
              pickInvoiceImage: pickInvoiceImage,
              imageError: imageError,
              fieldsEnabled: fieldsEnabled,
              businessNameValidator: businessNameValidator,
              receiptNoValidator: receiptNoValidator,
              totalAmountValidator: totalAmountValidator,
              kdvAmountValidator: kdvAmountValidator,
              dateText: dateText,
              pickDate: pickDate,
              dateError: dateError,
              onCategoryChanged: onCategoryChanged,
              onKdvRateChanged: onKdvRateChanged,
              onPaymentTypeChanged: onPaymentTypeChanged,
              paymentType: paymentType,
              saving: saving,
              save: save,
              invoiceImage: invoiceImage,
              invoiceImageBytes: invoiceImageBytes,
              selectedCategory: selectedCategory,
              selectedKdvRate: selectedKdvRate,
            ),
          ],
        ),
      ),
    );
  }
}
