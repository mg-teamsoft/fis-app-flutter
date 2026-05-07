part of '../../page/receipt_table_page.dart';

class _ReceiptTableTextRow extends StatefulWidget {
  const _ReceiptTableTextRow({
    required this.row,
    required this.scalarRows,
  });

  final int row;
  final List<
      ({
        TextEditingController ctrl,
        String key,
        String? err,
        bool highlight,
        String label,
        bool readOnly
      })> scalarRows;

  @override
  State<_ReceiptTableTextRow> createState() => _ReceiptTableTextRowState();
}

class _ReceiptTableTextRowState extends State<_ReceiptTableTextRow> {
  late bool _hasError;
  late String? _err;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _validateCurrentRow();
  }

  @override
  void didUpdateWidget(covariant _ReceiptTableTextRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validateCurrentRow();
  }

  bool _isNumericKey(String key) =>
      key == 'vatRate' || key == 'vatAmount' || key == 'totalAmount';

  void _validateCurrentRow() {
    final scalarRow = widget.scalarRows[widget.row];
    _fieldCTRL(
      required: scalarRow.err != null,
      numeric: _isNumericKey(scalarRow.key),
    );
  }

  void _fieldCTRL({
    bool required = false,
    bool numeric = false,
  }) {
    final scalarRow = widget.scalarRows[widget.row];
    final val = scalarRow.ctrl.text.trim();
    final numValue = double.tryParse(val);
    _hasError = false;
    _err = null;

    if (scalarRow.key == 'businessName') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'İşletme adı boş olamaz' : null;
    } else if (scalarRow.key == 'transactionDate') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'İşlem tarihi boş olamaz' : null;
    } else if (scalarRow.key == 'receiptNumber') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'Fiş numarası boş olamaz' : null;
    } else if (scalarRow.key == 'vatRate') {
      _hasError = numeric && (numValue == null || numValue <= 0);
      _err = _hasError ? 'KDV oranı 0 dan büyük olmalıdır' : null;
    } else if (scalarRow.key == 'vatAmount') {
      _hasError = numeric && (numValue == null || numValue <= 0);
      _err = _hasError ? 'KDV tutarı 0 dan büyük olmalıdır' : null;
    } else if (scalarRow.key == 'totalAmount') {
      _hasError = numeric && (numValue == null || numValue < 0);
      _err = _hasError ? 'Toplam tutar 0 dan büyük veya eşit olmalıdır' : null;
    } else if (scalarRow.key == 'businessTaxNo') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'İşletme vergi numarası boş olamaz' : null;
    } else if (scalarRow.key == 'transactionType') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'İşlem türü boş olamaz' : null;
    } else if (scalarRow.key == 'paymentType') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'Ödeme türü boş olamaz' : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scalarRow = widget.scalarRows[widget.row];

    return Padding(
      padding: ThemePadding.horizontalSymmetricFree(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: ThemeSize.avatarXL,
              child: ThemeTypography.labelMedium(
                context,
                _hasError ? '⚠️ ${scalarRow.label}' : scalarRow.label,
                color: _hasError
                    ? context.theme.error
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: ThemeSize.spacingS),
          Expanded(
            child: TextField(
              controller: scalarRow.ctrl,
              textAlign: TextAlign.right,
              readOnly: scalarRow.readOnly,
              onChanged: (value) {
                _fieldCTRL(
                  required: scalarRow.err != null,
                  numeric: _isNumericKey(scalarRow.key),
                );
                setState(() {});
              },
              style: scalarRow.highlight
                  ? context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.primary,
                    )
                  : context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scalarRow.readOnly
                          ? context.colorScheme.onSurfaceVariant
                          : null,
                    ),
              decoration: _inputDecoration(
                context,
                _hasError ? '⚠️' : '',
                isError: _hasError,
                errorText: scalarRow.err,
              ).copyWith(
                fillColor: scalarRow.readOnly
                    ? context.colorScheme.surfaceContainerHighest
                    : null,
                hintText: scalarRow.readOnly ? 'Otomatik hesaplanır' : _err,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
