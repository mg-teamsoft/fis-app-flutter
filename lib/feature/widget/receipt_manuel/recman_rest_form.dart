part of '../../page/receipt_manuel_page.dart';

class _ReceiptManuelRestForm extends StatefulWidget {
  const _ReceiptManuelRestForm({
    required this.businessNameController,
    required this.receiptNoController,
    required this.kdvAmountController,
    required this.totalAmountController,
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
    required this.recalculateKdv,
    required this.paymentType,
    required this.saving,
    required this.save,
    this.invoiceImage,
    this.invoiceImageBytes,
    this.selectedCategory,
    this.selectedKdvRate,
  });

  final TextEditingController businessNameController;
  final TextEditingController receiptNoController;
  final TextEditingController kdvAmountController;
  final TextEditingController totalAmountController;
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
  final void Function() recalculateKdv;
  final String paymentType;
  final bool saving;
  final Future<void> Function() save;

  @override
  State<_ReceiptManuelRestForm> createState() => __ReceiptManuelRestFormState();
}

class __ReceiptManuelRestFormState extends State<_ReceiptManuelRestForm> {
  ReceiptCategory? _selectedCategory;
  String? _selectedKdvRate;
  String _paymentType = 'cash';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedKdvRate = widget.selectedKdvRate;
    _paymentType = widget.paymentType;
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !widget.fieldsEnabled,
      child: Opacity(
        opacity: widget.fieldsEnabled ? 1.0 : 0.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('İşletme Adı*'),
            const SizedBox(height: 8),
            _TextFieldBox(
              controller: widget.businessNameController,
              hintText: 'Acme Corp',
              validator: widget.businessNameValidator,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Tarih*'),
                      const SizedBox(height: 8),
                      _DateFieldBox(
                        value: widget.dateText,
                        onTap: widget.pickDate,
                        hasError: widget.dateError,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Fiş No*'),
                      const SizedBox(height: 8),
                      _TextFieldBox(
                        controller: widget.receiptNoController,
                        hintText: 'REC-12345',
                        validator: widget.receiptNoValidator,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _FieldLabel.rich(
              main: 'İşlem Türü',
              suffix: ' (Opsiyonel)',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ReceiptCategory.values.map((category) {
                return _ChoiceChipButton(
                  label: category.label,
                  selected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Toplam Tutar*'),
            const SizedBox(height: 8),
            _TextFieldBox(
              controller: widget.totalAmountController,
              hintText: '0.00',
              prefixText: '₺ ',
              keyboardType: TextInputType.number,
              inputFormatters: [_CurrencyInputFormatter()],
              textAlign: TextAlign.right,
              validator: widget.totalAmountValidator,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('KDV Oranı (%)'),
                      const SizedBox(height: 8),
                      _DropdownFieldBox(
                        value: _selectedKdvRate,
                        hintText: 'Oran Seç',
                        items: const ['1', '8', '10', '18', '20'],
                        onChanged: (value) {
                          setState(() => _selectedKdvRate = value);
                          widget.recalculateKdv();
                        },
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'KDV oranı seçiniz'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('KDV Tutarı*'),
                      const SizedBox(height: 8),
                      _TextFieldBox(
                        controller: widget.kdvAmountController,
                        hintText: '0.00',
                        prefixText: '₺ ',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        readOnly: true,
                        fillColor: const Color(0xFFF2F4F7),
                        validator: widget.kdvAmountValidator,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _FieldLabel.rich(
              main: 'Ödeme Türü',
              suffix: ' (Opsiyonel)',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ChoiceChipButton(
                  label: 'Nakit',
                  selected: _paymentType == 'cash',
                  onTap: () => setState(() => _paymentType = 'cash'),
                ),
                _ChoiceChipButton(
                  label: 'Kredi Kartı',
                  selected: _paymentType == 'card',
                  onTap: () => setState(() => _paymentType = 'card'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
