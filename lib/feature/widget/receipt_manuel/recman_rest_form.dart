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
    required this.onCategoryChanged,
    required this.onKdvRateChanged,
    required this.onPaymentTypeChanged,
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
  final void Function(ReceiptCategory?) onCategoryChanged;
  final void Function(String?) onKdvRateChanged;
  final void Function(String) onPaymentTypeChanged;
  final String paymentType;
  final bool saving;
  final Future<void> Function() save;

  @override
  State<_ReceiptManuelRestForm> createState() => __ReceiptManuelRestFormState();
}

class __ReceiptManuelRestFormState extends State<_ReceiptManuelRestForm> {
  ReceiptCategory? _selectedCategory;
  String _paymentType = 'cash';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _paymentType = widget.paymentType;
  }

  @override
  void didUpdateWidget(covariant _ReceiptManuelRestForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      _selectedCategory = widget.selectedCategory;
    }
    if (widget.selectedKdvRate != oldWidget.selectedKdvRate) {}
    if (widget.paymentType != oldWidget.paymentType) {
      _paymentType = widget.paymentType;
    }
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
            const SizedBox(height: ThemeSize.spacingS),
            _TextFieldBox(
              controller: widget.businessNameController,
              hintText: 'Acme Corp',
              validator: widget.businessNameValidator,
            ),
            const SizedBox(height: ThemeSize.spacingL),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Tarih*'),
                      const SizedBox(height: ThemeSize.spacingS),
                      _DateFieldBox(
                        value: widget.dateText,
                        onTap: widget.pickDate,
                        hasError: widget.dateError,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ThemeSize.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Fiş No*'),
                      const SizedBox(height: ThemeSize.spacingS),
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
            const SizedBox(height: ThemeSize.spacingL),
            const _FieldLabel.rich(
              main: 'İşlem Türü',
              suffix: ' (Opsiyonel)',
            ),
            const SizedBox(height: ThemeSize.spacingM),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ReceiptCategory.values.map((category) {
                return _ChoiceChipButton(
                  label: category.label,
                  selected: _selectedCategory == category,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    widget.onCategoryChanged(category);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: ThemeSize.spacingL),
            const _FieldLabel('Toplam Tutar*'),
            const SizedBox(height: ThemeSize.spacingS),
            _TextFieldBox(
              controller: widget.totalAmountController,
              hintText: '0.00',
              prefixText: '₺ ',
              keyboardType: TextInputType.number,
              inputFormatters: [_CurrencyInputFormatter()],
              textAlign: TextAlign.right,
              validator: widget.totalAmountValidator,
            ),
            const SizedBox(height: ThemeSize.spacingL),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('KDV Oranı (%)'),
                      const SizedBox(height: ThemeSize.spacingS),
                      _DropdownFieldBox(
                        value: widget.selectedKdvRate,
                        hintText: 'Oran Seç',
                        items: const ['1', '8', '10', '18', '20'],
                        onChanged: (value) {
                          widget.onKdvRateChanged(value);
                        },
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'KDV oranı seçiniz'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ThemeSize.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('KDV Tutarı*'),
                      const SizedBox(height: ThemeSize.spacingS),
                      _TextFieldBox(
                        controller: widget.kdvAmountController,
                        hintText: '0.00',
                        prefixText: '₺ ',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        readOnly: true,
                        fillColor: context.colorScheme.surfaceContainer,
                        validator: widget.kdvAmountValidator,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeSize.spacingL),
            const _FieldLabel.rich(
              main: 'Ödeme Türü',
              suffix: ' (Opsiyonel)',
            ),
            const SizedBox(height: ThemeSize.spacingM),
            Wrap(
              spacing: ThemeSize.spacingM,
              runSpacing: ThemeSize.spacingM,
              children: [
                _ChoiceChipButton(
                  label: 'Nakit',
                  selected: _paymentType == 'cash',
                  onTap: () {
                    setState(() => _paymentType = 'cash');
                    widget.onPaymentTypeChanged('cash');
                  },
                ),
                _ChoiceChipButton(
                  label: 'Kredi Kartı',
                  selected: _paymentType == 'card',
                  onTap: () {
                    setState(() => _paymentType = 'card');
                    widget.onPaymentTypeChanged('card');
                  },
                ),
              ],
            ),
            const SizedBox(height: ThemeSize.spacingXXXl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.save,
                icon: Icon(
                  Icons.save,
                  size: ThemeSize.iconMedium,
                  color: context.colorScheme.onPrimary,
                ),
                label: ThemeTypography.bodyLarge(
                  context,
                  'Kaydet',
                  color: context.colorScheme.onPrimary,
                  weight: FontWeight.w900,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  padding: const ThemePadding.verticalSymmetricMedium(),
                  minimumSize:
                      const Size.fromHeight(ThemeSize.buttonHeightLarge),
                  shape: RoundedRectangleBorder(
                    borderRadius: ThemeRadius.circular12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: ThemeSize.spacingXXXl),
          ],
        ),
      ),
    );
  }
}
