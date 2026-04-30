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
    _fieldCTRL(
      required: widget.scalarRows[widget.row].err != null,
      numeric: widget.scalarRows[widget.row].key == 'vatRate' ||
          widget.scalarRows[widget.row].key == 'vatAmount' ||
          widget.scalarRows[widget.row].key == 'totalAmount',
    );
  }

  void _fieldCTRL({
    bool required = false,
    bool numeric = false,
  }) {
    final val = widget.scalarRows[widget.row].ctrl.text.trim();
    final numValue = double.tryParse(val);
    if (widget.scalarRows[widget.row].key == 'businessName') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'İşletme adı boş olamaz' : null;
    } else if (widget.scalarRows[widget.row].key == 'transactionDate') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'İşlem tarihi boş olamaz' : null;
    } else if (widget.scalarRows[widget.row].key == 'receiptNumber') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'Fiş numarası boş olamaz' : null;
    } else if (widget.scalarRows[widget.row].key == 'vatRate') {
      _hasError = numeric && (numValue == null || numValue <= 0);
      _err = _hasError ? 'KDV oranı 0 dan büyük olmalıdır' : null;
    } else if (widget.scalarRows[widget.row].key == 'vatAmount') {
      _hasError = numeric && (numValue == null || numValue <= 0);
      _err = _hasError ? 'KDV tutarı 0 dan büyük olmalıdır' : null;
    } else if (widget.scalarRows[widget.row].key == 'totalAmount') {
      _hasError = numeric && (numValue == null || numValue < 0);
      _err = _hasError ? 'Toplam tutar 0 dan büyük veya eşit olmalıdır' : null;
    } else if (widget.scalarRows[widget.row].key == 'businessTaxNo') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'İşletme vergi numarası boş olamaz' : null;
    } else if (widget.scalarRows[widget.row].key == 'transactionType') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'İşlem türü boş olamaz' : null;
    } else if (widget.scalarRows[widget.row].key == 'paymentType') {
      _hasError = required && val.isEmpty;
      _err = _hasError ? 'Ödeme türü boş olamaz' : null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _hasError
                    ? '⚠️ ${widget.scalarRows[widget.row].label}'
                    : widget.scalarRows[widget.row].label,
                color: _hasError
                    ? context.theme.error
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: ThemeSize.spacingS),
          Expanded(
            child: TextField(
              controller: widget.scalarRows[widget.row].ctrl,
              textAlign: TextAlign.right,
              readOnly: widget.scalarRows[widget.row].readOnly,
              onChanged: (value) {
                _fieldCTRL(required: widget.scalarRows[widget.row].err != null);
                setState(() {});
              },
              style: widget.scalarRows[widget.row].highlight
                  ? context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.primary,
                    )
                  : context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.scalarRows[widget.row].readOnly
                          ? context.colorScheme.onSurfaceVariant
                          : null,
                    ),
              decoration: _inputDecoration(
                context,
                _hasError ? '⚠️' : '',
                isError: _hasError,
                errorText: widget.scalarRows[widget.row].err,
              ).copyWith(
                fillColor: widget.scalarRows[widget.row].readOnly
                    ? context.colorScheme.surfaceContainerHighest
                    : null,
                hintText: widget.scalarRows[widget.row].readOnly
                    ? 'Otomatik hesaplanır'
                    : _err!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
