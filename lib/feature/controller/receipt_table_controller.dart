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

  bool _businessCTRL = false;
  bool _dateCTRL = false;
  bool _receiptNoCTRL = false;
  bool _transTypeCTRL = false;
  bool _paymentTypeCTRL = false;
  bool _vatRateCTRL = false;
  bool _businessTaxNoCTRL = false;
  bool _vatCTRL = false;
  bool _totalCTRL = false;

  Map<String, dynamic>? get _extras =>
      _pick<Map<String, dynamic>>(['Diğer Alanlar']);

  List<
      ({
        TextEditingController ctrl,
        String key,
        String? err,
        bool highlight,
        String label,
        bool hasError,
        bool readOnly
      })> get _scalarRows => <({
        String label,
        String key,
        TextEditingController ctrl,
        bool highlight,
        bool readOnly,
        bool hasError,
        String? err,
      })>[
        (
          label: 'Şirket Adı',
          key: 'businessName',
          ctrl: _businessName,
          highlight: false,
          readOnly: false,
          hasError: _businessCTRL,
          err: _errorOf('businessName', _businessName, required: true)
        ),
        (
          label: 'Tarih',
          key: 'transactionDate',
          ctrl: _date,
          highlight: false,
          readOnly: false,
          hasError: _dateCTRL,
          err: _errorOf('transactionDate', _date, required: true)
        ),
        (
          label: 'Fiş No',
          key: 'receiptNumber',
          ctrl: _receiptNo,
          highlight: false,
          readOnly: false,
          hasError: _receiptNoCTRL,
          err: _errorOf('receiptNumber', _receiptNo)
        ),
        // KDV Tutarı — editable, value comes from backend
        (
          label: 'KDV Tutarı',
          key: 'vatAmount',
          ctrl: _vat,
          highlight: false,
          readOnly: false,
          hasError: _vatCTRL,
          err: _errorOf('vatAmount', _vat, numeric: true)
        ),
        (
          label: 'Toplam Tutar',
          key: 'totalAmount',
          ctrl: _total,
          highlight: true,
          readOnly: false,
          hasError: _totalCTRL,
          err: _errorOf('totalAmount', _total, required: true, numeric: true)
        ),
        (
          label: 'İşlem Türü',
          key: 'transactionType',
          ctrl: _transType,
          highlight: false,
          readOnly: false,
          hasError: _transTypeCTRL,
          err: _errorOf('transactionType', _transType)
        ),
        (
          label: 'Ödeme Türü',
          key: 'paymentType',
          ctrl: _paymentType,
          highlight: false,
          readOnly: false,
          hasError: _paymentTypeCTRL,
          err: _errorOf('paymentType', _paymentType)
        ),
        (
          label: 'KDV (%)',
          key: 'vatRate',
          ctrl: _vatRate,
          highlight: false,
          readOnly: false,
          hasError: _vatRateCTRL,
          err: _errorOf('vatRate', _vatRate, numeric: true)
        ),
        (
          label: 'Vergi No',
          key: 'businessTaxNo',
          ctrl: _businessTaxNo,
          highlight: false,
          readOnly: false,
          hasError: _businessTaxNoCTRL,
          err: _errorOf('businessTaxNo', _businessTaxNo)
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
    String key,
    TextEditingController ctrl, {
    bool required = false,
    bool numeric = false,
  }) {
    final val = ctrl.text.trim();
    final numValue = double.tryParse(val);

    if (key == 'businessName') {
      _businessCTRL = required && val.isEmpty;
    } else if (key == 'transactionDate') {
      _dateCTRL = required && val.isEmpty;
    } else if (key == 'receiptNumber') {
      _receiptNoCTRL = required && val.isEmpty;
    } else if (key == 'vatRate') {
      _vatRateCTRL = numeric && (numValue == null || numValue <= 0);
    } else if (key == 'vatAmount') {
      _vatCTRL = numeric && (numValue == null || numValue <= 0);
    } else if (key == 'totalAmount') {
      _totalCTRL = numeric && (numValue == null || numValue < 0);
    } else if (key == 'businessTaxNo') {
      _businessTaxNoCTRL = required && val.isEmpty;
    } else if (key == 'transactionType') {
      _transTypeCTRL = required && val.isEmpty;
    } else if (key == 'paymentType') {
      _paymentTypeCTRL = required && val.isEmpty;
    }

    if (!widget.showErrors) return null;

    if (required && val.isEmpty) {
      return 'Bu alan zorunludur';
    }

    if (numeric && val.isNotEmpty && numValue == null) {
      return 'Geçerli bir sayı girin';
    }

    return null;
  }
}
