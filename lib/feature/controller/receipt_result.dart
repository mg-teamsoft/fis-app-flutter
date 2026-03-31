part of '../page/receipt_result.dart';

mixin _ConnectionReceiptResult on State<PageReceiptResult> {
  final _jobs = JobService();
  final _excel = ExcelService();
  bool _submitting = false;
  bool? _hasSuccessfulSubmission;
  final bool _showOnlySelected = false;
  final Map<String, Future<Uint8List>> _bytesCache = {};
  late final List<SelectedItem> _items;

  static const Set<String> _localizedReceiptKeys = {
    'Şirket Adı',
    'İşlem Tarihi',
    'Fiş No',
    'KDV Tutarı',
    'Toplam Tutar',
    'KDV Oranı (%)',
    'İşlem Tipi',
    'Ödeme Tipi',
    'Ürünler',
    'Diğer Alanlar',
  };

  static const Set<String> _englishReceiptKeys = {
    'businessName',
    'companyName',
    'receiptNumber',
    'transactionDate',
    'products',
    'vatAmount',
    'kdvAmount',
    'totalAmount',
    'vatRate',
    'transactionType',
    'paymentType',
  };

  /// Per-item UI + polling state
  final Map<String, _ItemState> _state = {}; // key: jobId

  Timer? _tick; // global 1s ticker for countdowns

  @override
  void initState() {
    super.initState();

    _items = _items.where((it) {
      final jobId = it.jobId;
      if (jobId == null) return false;
      if (!_showOnlySelected) return true;
      final s = _state[jobId];
      return s?.selected ?? s?.receipt != null;
    }).toList();
    unawaited(_startTicker());
  }

  @override
  void dispose() {
    _tick?.cancel();
    for (final s in _state.values) {
      s.controller?.dispose();
    }
    super.dispose();
  }

  Future<void> _startTicker() async {
    // Tick every 1s to drive the 10s countdowns
    _tick = Timer.periodic(const Duration(seconds: 1), (t) async {
      var anyActive = false;

      for (final s in _state.values) {
        if (!s.active) continue; // already done/failed
        anyActive = true;

        // decrement countdown
        s.countdown--;
        if (s.countdown <= 0) {
          // time to poll the backend for this job
          s.countdown = 10; // reset for the next round if still running
          await _pollOne(s);
        }
      }

      if (!mounted) return;
      setState(() {});

      if (!anyActive) {
        // all items have finished
        _tick?.cancel();
      }
    });

    // Kick an initial poll immediately (no need to wait 10s for first update)
    for (final s in _state.values) {
      await _pollOne(s);
    }
  }

  Future<void> _pollOne(_ItemState s) async {
    final jobId = s.item.jobId!;
    try {
      final resp = await _jobs.getJob(jobId);

      final jobObj = (resp['job'] is Map)
          ? Map<String, dynamic>.from(resp['job'] as Map)
          : Map<String, dynamic>.from(resp as Map);

      s.status = (jobObj['status'] as String?) ?? s.status;
      final message = jobObj['message']?.toString();

      final raw = jobObj['receipt'];
      Map<String, dynamic>? asMap;
      if (raw == null) {
        asMap = null;
      } else if (raw is Map<String, dynamic>) {
        asMap = raw;
      } else if (raw is String) {
        try {
          final parsed = jsonDecode(raw);
          if (parsed is Map<String, dynamic>) asMap = parsed;
        } on FormatException catch (_) {
          asMap = null;
        }
      }

      final localizedReceipt = _localizeReceipt(asMap);
      s.rawReceipt = asMap;

      if (s.status == StatusType.done.name) {
        s
          ..lastError = null
          ..active = false
          ..countdown = 0
          ..receipt = localizedReceipt
          ..selected ??= localizedReceipt != null;

        // Keep controller for approve flow
        final editorText = (localizedReceipt != null)
            ? const JsonEncoder.withIndent('  ').convert(localizedReceipt)
            : message ?? 'fiş datası okunamadı.';

        if (s.controller == null) {
          s.controller = TextEditingController(text: editorText);
        } else {
          s.controller!.text = editorText;
        }
      } else if (s.status == StatusType.failed.name ||
          s.status == StatusType.error.name) {
        s
          ..lastError = message ?? 'İşlem sırasında hata oluştu.'
          ..active = false
          ..countdown = 0
          ..receipt = localizedReceipt
          ..selected ??= false;

        final editorText = (localizedReceipt != null)
            ? const JsonEncoder.withIndent('  ').convert(localizedReceipt)
            : s.lastError!;

        if (s.controller == null) {
          s.controller = TextEditingController(text: editorText);
        } else {
          s.controller!.text = editorText;
        }
      } else {
        s
          ..active = true
          ..lastError = message;
      }
    } on Exception catch (e) {
      s.lastError = e.toString();
    }

    if (mounted) setState(() {});
  }

  void _removeItem(SelectedItem it) {
    final jobId = it.jobId;
    if (jobId != null && _state.containsKey(jobId)) {
      _state[jobId]?.controller?.dispose();
      _state[jobId]?.photoController?.dispose();
      _state.remove(jobId);
    }
    setState(() {
      _items.removeWhere((x) => x.jobId == jobId);
    });
  }

  void _rotateImage(_ItemState s) {
    s.photoController ??= PhotoViewController();
    s.rotationDeg = (s.rotationDeg + 90) % 360;
    s.photoController!.rotation = s.rotationDeg * math.pi / 180;
    setState(() {});
  }

  // ── validation helpers ─────────────────────────────────────────────────────
  static List<String> _collectErrors(Map<String, dynamic>? receipt) {
    if (receipt == null) return ['Fiş verisi eksik.'];
    final errors = <String>[];

    void requireField(String key, String label) {
      final v = receipt[key]?.toString().trim() ?? '';
      if (v.isEmpty) errors.add('$label zorunludur.');
    }

    void requireNumeric(String key, String label) {
      final v = receipt[key]?.toString().trim() ?? '';
      if (v.isNotEmpty && double.tryParse(v) == null) {
        errors.add('$label geçerli bir sayı olmalıdır.');
      }
    }

    requireField('Şirket Adı', 'Şirket Adı');
    requireField('İşlem Tarihi', 'İşlem Tarihi');
    requireField('Toplam Tutar', 'Toplam Tutar');
    requireNumeric('Toplam Tutar', 'Toplam Tutar');
    requireNumeric('KDV Tutarı', 'KDV Tutarı');
    requireNumeric('KDV Oranı (%)', 'KDV Oranı');

    final products = receipt['Ürünler'];
    if (products is List) {
      for (var i = 0; i < products.length; i++) {
        final p = products[i];
        if (p is Map) {
          final name = p['Ürün Adı']?.toString().trim() ?? '';
          if (name.isEmpty) errors.add('Ürün ${i + 1}: Ürün Adı zorunludur.');
          for (final f in ['Miktar', 'Birim Fiyat', 'Satır Toplamı']) {
            final v = p[f]?.toString().trim() ?? '';
            if (v.isNotEmpty && double.tryParse(v) == null) {
              errors.add('Ürün ${i + 1}: $f geçerli bir sayı olmalıdır.');
            }
          }
        }
      }
    }
    return errors;
  }

  Future<void> _approveAll() async {
    if (_submitting) return;

    // ── pre-flight validation ──────────────────────────────────────────────
    var anyValidationError = false;
    for (final s in _state.values) {
      final isSelected = s.selected ?? (s.receipt != null);
      if (!isSelected) continue;
      if (s.status != StatusType.done.name) continue;
      final errors = _collectErrors(s.receipt);
      if (errors.isNotEmpty) {
        s.showErrors = true;
        anyValidationError = true;
      }
    }

    if (anyValidationError) {
      setState(() {});
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Lütfen kırmızı alanları düzeltin.'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
      return;
    }
    // ── end validation ────────────────────────────────────────────────────

    setState(() {
      _submitting = true;
      _hasSuccessfulSubmission = null;
    });

    var okCount = 0;
    var failCount = 0;
    final failures = <String>[];

    for (final entry in _state.entries) {
      final s = entry.value;
      final isSelected = s.selected ?? (s.receipt != null);
      if (!isSelected) continue;

      final ctrl = s.controller;
      if (ctrl == null) continue;

      if (s.status != StatusType.done.name) continue;

      try {
        final text = ctrl.text.trim();
        if (text.toLowerCase().contains('can not read receipt data')) {
          failCount++;
          failures.add('${s.item.jobId}: empty');
          continue;
        }

        final dynamic decoded = json.decode(text);
        if (decoded is! Map) {
          failCount++;
          failures.add('${s.item.jobId}: geçersiz JSON');
          continue;
        }

        final edited = Map<String, dynamic>.from(decoded);
        final normalized = _delocalizeReceiptIfNeeded(edited);

        final key = s.item.key;
        if (key == null || key.isEmpty) {
          failCount++;
          failures.add('${s.item.jobId}: missing key');
          continue;
        }

        // The backend's mapReceiptDataToReceiptModel mutates transactionType.kdvRate,
        // so it must be an object. _delocalizeReceiptIfNeeded flattens it to a string;
        // reconstruct the object here using the vatRate that was already extracted.
        final txType = normalized['transactionType'];
        if (txType is String) {
          normalized['transactionType'] = <String, dynamic>{
            'type': txType,
            'kdvRate': normalized['vatRate'] ?? 0,
          };
        }

        final ok = await _excel.pushReceipt(key, normalized);
        if (ok) {
          okCount++;
        } else {
          failCount++;
          failures.add('${s.item.jobId}: excel write failed');
        }
      } on Exception catch (e) {
        failCount++;
        failures.add('${s.item.jobId}: $e');
      }
    }

    if (!mounted) return;

    final msg = (failures.isEmpty)
        ? "✅ $okCount fiş Excel'e yazıldı"
        : '✅ $okCount yazıldı • ❌ $failCount başarısız\n${failures.join('\n')}';

    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );

    setState(() {
      _submitting = false;
      _hasSuccessfulSubmission = okCount > 0;
    });

    // Navigate to Excel files page on full success
    if (okCount > 0 && failures.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      await Navigator.of(context as BuildContext).pushNamedAndRemoveUntil(
        '/excelFiles',
        (route) => route.isFirst,
      );
    }
  }

  Map<String, dynamic>? _localizeReceipt(Map<String, dynamic>? raw) {
    if (raw == null) return null;

    final localized = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      localized[key] = value;
    }

    put('Şirket Adı', raw['businessName'] ?? raw['companyName']);

    // Parse ISO date to dd.MM.yyyy for display
    final rawDate = raw['transactionDate']?.toString() ?? '';
    if (rawDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawDate);
        put(
          'İşlem Tarihi',
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}',
        );
      } on Exception catch (_) {
        put('İşlem Tarihi', rawDate);
      }
    }

    put('Fiş No', raw['receiptNumber']);
    // vatAmount is the standard key; fall back to legacy kdvAmount
    put('KDV Tutarı', raw['vatAmount'] ?? raw['kdvAmount']);
    // vatRate is a top-level numeric field
    put('KDV Oranı (%)', raw['vatRate']);
    put('Toplam Tutar', raw['totalAmount']);
    put('Ödeme Türü', raw['paymentType']);

    // transactionType may be a plain string or an object with 'type' + 'kdvRate'
    final transactionType = raw['transactionType'];
    if (transactionType is Map) {
      final typed = Map<String, dynamic>.from(transactionType);
      put('İşlem Türü', typed['type'] ?? typed['name']);
      // kdvRate lives inside the transactionType object
      if (typed['kdvRate'] != null) {
        put('KDV Oranı (%)', typed['kdvRate']);
      }
    } else if (transactionType != null) {
      put('İşlem Türü', transactionType);
    }

    final products = raw['products'];
    if (products is List) {
      final localizedProducts = products
          .whereType<Map<String, dynamic>>()
          .map(_localizeProduct)
          .where((p) => p.isNotEmpty)
          .toList();
      if (localizedProducts.isNotEmpty) {
        localized['Ürünler'] = localizedProducts;
      }
    }

    // Carry through any extra unknown DB fields into 'Diğer Alanlar'
    final extras = <String, dynamic>{};
    raw.forEach((key, value) {
      if (!_englishReceiptKeys.contains(key)) {
        extras[key] = value;
      }
    });
    if (extras.isNotEmpty) {
      final merged = <String, dynamic>{
        ...?localized['Diğer Alanlar'] as Map<String, dynamic>?,
        ...extras,
      };
      if (merged.isNotEmpty) {
        localized['Diğer Alanlar'] = merged;
      }
    }

    return localized.isEmpty ? null : localized;
  }

  Map<String, dynamic> _localizeProduct(Map<String, dynamic> raw) {
    final localized = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value == null) return;
      localized[key] = value;
    }

    put('Ürün Adı', raw['name'] ?? raw['productName']);
    put('Miktar', raw['quantity']);
    put('Birim Fiyat', raw['unitPrice']);
    put('Satır Toplamı', raw['lineTotal']);

    final extras = Map<String, dynamic>.from(raw)
      ..remove('name')
      ..remove('productName')
      ..remove('quantity')
      ..remove('unitPrice')
      ..remove('lineTotal');
    if (extras.isNotEmpty) {
      localized['Ek Bilgi'] = extras;
    }

    return localized;
  }

  Map<String, dynamic> _delocalizeReceiptIfNeeded(Map<String, dynamic> source) {
    final containsLocalizedKey =
        source.keys.any((key) => _localizedReceiptKeys.contains(key));
    if (!containsLocalizedKey) {
      return source;
    }

    final normalized = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value == null) return;
      normalized[key] = value;
    }

    put(
      'businessName',
      source['Şirket Adı'] ?? source['isletmeAdi'] ?? source['firmaAdi'],
    );
    put(
      'receiptNumber',
      source['Fiş No'] ?? source['fisNumarasi'] ?? source['fisNo'],
    );
    put(
      'transactionDate',
      source['İşlem Tarihi'] ?? source['islemTarihi'],
    );
    put(
      'vatAmount',
      source['KDV Tutarı'] ?? source['kdvTutari'],
    );
    put(
      'vatRate',
      source['KDV Oranı (%)'] ?? source['kdvOrani'],
    );
    put(
      'totalAmount',
      source['Toplam Tutar'] ?? source['toplamTutar'],
    );
    put(
      'paymentType',
      source['Ödeme Türü'] ?? source['Ödeme Tipi'] ?? source['odemeTipi'],
    );
    put(
      'transactionType',
      source['İşlem Türü'] ?? source['İşlem Tipi'] ?? source['islemTipi'],
    );

    final urunler = source['Ürünler'] ?? source['urunler'];
    if (urunler is List) {
      final products = urunler
          .whereType<Map<String, dynamic>>()
          .map(_delocalizeProduct)
          .where((p) => p.isNotEmpty)
          .toList();
      if (products.isNotEmpty) {
        normalized['products'] = products;
      }
    }

    final extras =
        source['Diğer Alanlar'] ?? source['digerAlanlar'] ?? source['diger'];
    if (extras is Map) {
      normalized.addAll(Map<String, dynamic>.from(extras));
    }

    return normalized;
  }

  Map<String, dynamic> _delocalizeProduct(Map<String, dynamic> source) {
    final normalized = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value == null) return;
      normalized[key] = value;
    }

    put('name', source['Ürün Adı'] ?? source['urunAdi'] ?? source['ad']);
    put('quantity', source['Miktar'] ?? source['miktar']);
    put('unitPrice', source['Birim Fiyat'] ?? source['birimFiyat']);
    put('lineTotal', source['Satır Toplamı'] ?? source['satirToplami']);

    final extras = source['Ek Bilgi'] ?? source['diger'];
    if (extras is Map) {
      normalized.addAll(Map<String, dynamic>.from(extras));
    }

    return normalized;
  }
}
