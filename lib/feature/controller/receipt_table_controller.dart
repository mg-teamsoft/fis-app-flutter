part of '../page/receipt_table_page.dart';

mixin _ConnectionReceiptTable on State<PageReceiptTable> {
  late Map<String, dynamic> _current;

  late final TextEditingController _businessName;
  late final TextEditingController _date;
  late final TextEditingController _receiptNo;
  late final TextEditingController _transType;
  late final TextEditingController _paymentType;
  late final TextEditingController _vatRate;
  late final TextEditingController _businessTaxNo;
  late final TextEditingController _vat;
  late final TextEditingController _total;

  Map<String, dynamic>? get _extras =>
      _pick<Map<String, dynamic>>(['Diğer Alanlar']);

  List<
      ({
        TextEditingController ctrl,
        String? err,
        bool highlight,
        String label,
        bool readOnly
      })> get _scalarRows => <({
        String label,
        TextEditingController ctrl,
        bool highlight,
        bool readOnly,
        String? err,
      })>[
        (
          label: 'Şirket Adı',
          ctrl: _businessName,
          highlight: false,
          readOnly: false,
          err: _errorOf(_businessName, required: true)
        ),
        (
          label: 'Tarih',
          ctrl: _date,
          highlight: false,
          readOnly: false,
          err: _errorOf(_date, required: true)
        ),
        (
          label: 'Fiş No',
          ctrl: _receiptNo,
          highlight: false,
          readOnly: false,
          err: _errorOf(_receiptNo)
        ),
        // KDV Tutarı — editable, value comes from backend
        (
          label: 'KDV Tutarı',
          ctrl: _vat,
          highlight: false,
          readOnly: false,
          err: _errorOf(_vat, numeric: true)
        ),
        (
          label: 'Toplam Tutar',
          ctrl: _total,
          highlight: true,
          readOnly: false,
          err: _errorOf(_total, required: true, numeric: true)
        ),
        (
          label: 'İşlem Türü',
          ctrl: _transType,
          highlight: false,
          readOnly: false,
          err: _errorOf(_transType)
        ),
        (
          label: 'Ödeme Türü',
          ctrl: _paymentType,
          highlight: false,
          readOnly: false,
          err: _errorOf(_paymentType)
        ),
        (
          label: 'KDV (%)',
          ctrl: _vatRate,
          highlight: false,
          readOnly: false,
          err: _errorOf(_vatRate, numeric: true)
        ),
        (
          label: 'Vergi No',
          ctrl: _businessTaxNo,
          highlight: false,
          readOnly: false,
          err: _errorOf(_businessTaxNo)
        ),
      ];

  @override
  void initState() {
    super.initState();
    _current = Map<String, dynamic>.from(widget.data);
    _initControllers();
  }

  void _initControllers() {
    _businessName = TextEditingController(
      text: _pick<String>(['Şirket Adı', 'businessName', 'companyName']) ?? '',
    );
    _date = TextEditingController(
      text: _pick<String>(['İşlem Tarihi', 'transactionDate']) ?? '',
    );
    _receiptNo = TextEditingController(
      text: _pick<String>(['Fiş No', 'receiptNumber']) ?? '',
    );

    _transType = TextEditingController(
      text: _fmt(
        _pick<dynamic>(['İşlem Türü', 'İşlem Tipi', 'transactionType']),
      ),
    );
    _paymentType = TextEditingController(
      text: _pick<String>(['Ödeme Türü', 'Ödeme Tipi', 'paymentType']) ?? '',
    );
    _vatRate = TextEditingController(
      text: _fmt(_pick<dynamic>(['KDV (%)', 'KDV Oranı (%)', 'vatRate'])),
    );
    _businessTaxNo = TextEditingController(
      text: _fmt(
        _pick<dynamic>(['Vergi No', 'Vergi Numarası', 'businessTaxNo']),
      ),
    );

    _vat = TextEditingController(
      text: _fmt(_pick<dynamic>(['KDV Tutarı', 'kdvAmount', 'vatAmount'])),
    );
    _total = TextEditingController(
      text: _fmt(_pick<dynamic>(['Toplam Tutar', 'totalAmount'])),
    );

    // Attach listeners for all editable scalar controllers
    for (final ctrl in [
      _businessName,
      _date,
      _receiptNo,
      _transType,
      _paymentType,
      _vatRate,
      _businessTaxNo,
      _vat,
      _total,
    ]) {
      ctrl.addListener(_onScalarChanged);
    }
  }

  @override
  void dispose() {
    for (final ctrl in [
      _businessName,
      _date,
      _receiptNo,
      _transType,
      _paymentType,
      _vatRate,
      _businessTaxNo,
      _vat,
      _total,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  T? _pick<T>(List<String> keys) {
    for (final k in keys) {
      final v = _current[k];
      if (v != null) return v as T?;
    }
    return null;
  }

  String _fmt(dynamic v) {
    if (v == null) return '';
    if (v is Map) return v.values.join(' / ');
    return v.toString();
  }

  void _onScalarChanged() {
    _current['Şirket Adı'] = _businessName.text;
    _current['İşlem Tarihi'] = _date.text;
    _current['Fiş No'] = _receiptNo.text;
    _current['İşlem Tipi'] = _transType.text;
    _current['Ödeme Tipi'] = _paymentType.text;
    _current['KDV (%)'] = _vatRate.text;
    _current['Vergi No'] = _businessTaxNo.text;
    _current['KDV Tutarı'] = _vat.text;
    _current['Toplam Tutar'] = _total.text;
    // Remove old English keys that may have come from the backend
    [
      'businessName',
      'companyName',
      'transactionDate',
      'receiptNumber',
      'transactionType',
      'paymentType',
      'kdvAmount',
      'vatAmount',
      'vatRate',
      'KDV Oranı (%)',
      'Vergi Numarası',
      'businessTaxNo',
      'totalAmount',
    ].forEach(_current.remove);
    widget.onChanged?.call(Map<String, dynamic>.from(_current));
  }

  String? _errorOf(
    TextEditingController ctrl, {
    bool required = false,
    bool numeric = false,
  }) {
    if (!widget.showErrors) return null;
    final val = ctrl.text.trim();
    if (required && val.isEmpty) return 'Bu alan zorunludur';
    if (numeric && val.isNotEmpty && double.tryParse(val) == null) {
      return 'Geçerli bir sayı girin';
    }
    return null;
  }
}
