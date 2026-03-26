import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../model/receipt_flow_models.dart';
import '../model/status_type.dart';
import '../services/excel_service.dart';
import '../services/job_service.dart';

class ReceiptResultsPage extends StatefulWidget {
  final List<SelectedItem> items;
  const ReceiptResultsPage({super.key, required this.items});

  @override
  State<ReceiptResultsPage> createState() => _ReceiptResultsPageState();
}

class _ReceiptResultsPageState extends State<ReceiptResultsPage> {
  final _jobs = JobService();
  final _excel = ExcelService();
  bool _submitting = false;
  bool? _hasSuccessfulSubmission;
  bool _showOnlySelected = false;
  final Map<String, Future<Uint8List>> _bytesCache = {};
  late final List<SelectedItem> _items;

  /// Per-item UI + polling state
  final Map<String, _ItemState> _state = {}; // key: jobId

  Timer? _tick; // global 1s ticker for countdowns

  @override
  void initState() {
    super.initState();
    _items = widget.items.where((it) => it.jobId != null).toList();
    for (final it in _items) {
      if (it.jobId == null) continue;
      _state[it.jobId!] = _ItemState(item: it);
    }
    _startTicker();
  }

  @override
  void dispose() {
    _tick?.cancel();
    for (final s in _state.values) {
      s.controller?.dispose();
    }
    super.dispose();
  }

  void _startTicker() {
    // Tick every 1s to drive the 10s countdowns
    _tick = Timer.periodic(const Duration(seconds: 1), (t) async {
      bool anyActive = false;

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
      _pollOne(s);
    }
  }

  Future<void> _pollOne(_ItemState s) async {
    final jobId = s.item.jobId!;
    try {
      final resp = await _jobs.getJob(jobId);

      final Map<String, dynamic> jobObj = (resp['job'] is Map)
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
        } catch (_) {
          asMap = null;
        }
      }

      final localizedReceipt = _localizeReceipt(asMap);
      s.rawReceipt = asMap;

      if (s.status == StatusType.done.name) {
        s.lastError = null;
        s.active = false;
        s.countdown = 0;
        s.receipt = localizedReceipt;
        s.selected ??= localizedReceipt != null;

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
        s.lastError = message ?? 'İşlem sırasında hata oluştu.';
        s.active = false;
        s.countdown = 0;
        s.receipt = localizedReceipt;
        s.selected ??= false;

        final editorText = (localizedReceipt != null)
            ? const JsonEncoder.withIndent('  ').convert(localizedReceipt)
            : s.lastError!;

        if (s.controller == null) {
          s.controller = TextEditingController(text: editorText);
        } else {
          s.controller!.text = editorText;
        }
      } else {
        s.active = true;
        s.lastError = message;
      }
    } catch (e) {
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
      for (int i = 0; i < products.length; i++) {
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
    bool anyValidationError = false;
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
      ScaffoldMessenger.of(context).showSnackBar(
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

    int okCount = 0;
    int failCount = 0;
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
      } catch (e) {
        failCount++;
        failures.add('${s.item.jobId}: ${e.toString()}');
      }
    }

    if (!mounted) return;

    final msg = (failures.isEmpty)
        ? '✅ $okCount fiş Excel\'e yazıldı'
        : '✅ $okCount yazıldı • ❌ $failCount başarısız\n${failures.join('\n')}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );

    setState(() {
      _submitting = false;
      _hasSuccessfulSubmission = okCount > 0;
    });

    // Navigate to Excel files page on full success
    if (okCount > 0 && failures.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/excelFiles',
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items.where((it) {
      final jobId = it.jobId;
      if (jobId == null) return false;
      if (!_showOnlySelected) return true;
      final s = _state[jobId];
      return (s?.selected ?? s?.receipt != null);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonuçlar'),
        actions: [
          IconButton(
            tooltip: _showOnlySelected
                ? 'Tüm fişleri göster'
                : 'Sadece seçilenleri göster',
            icon: Icon(
              Icons.filter_list,
              color: _showOnlySelected ? context.colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showOnlySelected = !_showOnlySelected;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final it = items[i];
                  final jobId = it.jobId!;
                  final s =
                      _state.putIfAbsent(jobId, () => _ItemState(item: it));
                  final wide = MediaQuery.of(context).size.width > 700;
                  final isSelected = s.selected ?? (s.receipt != null);
                  final submitted = _hasSuccessfulSubmission == true;
                  final controller =
                      s.photoController ??= PhotoViewController();

                  final image = ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? FutureBuilder<Uint8List>(
                            future: _bytesCache.putIfAbsent(
                              it.file.path,
                              () => it.file.readAsBytes(),
                            ),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return PhotoView(
                                imageProvider: MemoryImage(snap.data!),
                                controller: controller,
                                backgroundDecoration: const BoxDecoration(
                                    color: Colors.transparent),
                                minScale:
                                    PhotoViewComputedScale.contained * 0.95,
                                maxScale: PhotoViewComputedScale.covered * 4.0,
                                basePosition: Alignment.center,
                                tightMode: true,
                              );
                            },
                          )
                        : PhotoView(
                            imageProvider: FileImage(File(it.file.path)),
                            controller: controller,
                            backgroundDecoration:
                                const BoxDecoration(color: Colors.transparent),
                            minScale: PhotoViewComputedScale.contained * 0.95,
                            maxScale: PhotoViewComputedScale.covered * 4.0,
                            basePosition: Alignment.center,
                            tightMode: true,
                          ),
                  );

                  final editor =
                      _buildEditorArea(context, s, submitted: submitted);
                  final showControls = !submitted;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            if (showControls) ...[
                              Checkbox(
                                value: isSelected,
                                onChanged: (v) {
                                  setState(() {
                                    s.selected = v ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                'Fiş ${i + 1}',
                                style: context.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Döndür',
                              onPressed: () => _rotateImage(s),
                              icon: const Icon(Icons.rotate_right),
                            ),
                            if (showControls)
                              IconButton(
                                tooltip: 'Sil',
                                onPressed: () => _removeItem(it),
                                icon: const Icon(Icons.delete_outline),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AspectRatio(
                                        aspectRatio: 3 / 4, child: image),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: editor),
                                ],
                              )
                            : Column(
                                children: [
                                  AspectRatio(aspectRatio: 3 / 4, child: image),
                                  const SizedBox(height: 12),
                                  editor,
                                ],
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed:
                        (_submitting || _state.values.any((s) => s.active))
                            ? null
                            : _approveAll,
                    icon: const Icon(Icons.check),
                    label: Text(
                      _submitting
                          ? "Gönderiliyor..."
                          : _state.values.any((s) => s.active)
                              ? "İşleniyor..."
                              : "Onayla ve Excel'e Yaz",
                    ),
                  ),
                  if (_hasSuccessfulSubmission != null) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        final route = _hasSuccessfulSubmission!
                            ? '/excelFiles'
                            : '/receipt';
                        Navigator.pushNamed(context, route);
                      },
                      icon: Icon(_hasSuccessfulSubmission!
                          ? Icons.table_view
                          : Icons.receipt_long),
                      label: Text(_hasSuccessfulSubmission!
                          ? "Excel Dosya Sayfasına Git"
                          : "Başa Dön"),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorArea(BuildContext context, _ItemState s,
      {required bool submitted}) {
    final surface =
        context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);

    final running = s.active &&
        (s.status != StatusType.done.name &&
            s.status != StatusType.failed.name &&
            s.status != StatusType.error.name);

    final countdownText = running ? 'Tekrar sorgu: ${s.countdown}s' : '';

    return DecoratedBox(
      decoration: BoxDecoration(
          color: surface, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (running) ...[
              Text(countdownText, style: context.textTheme.bodyMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (10 - s.countdown).clamp(0, 10) / 10.0,
                minHeight: 6,
              ),
              if (s.lastError != null) ...[
                const SizedBox(height: 8),
                Text('Hata: ${s.lastError}',
                    style: const TextStyle(color: Color(0xFFD32F2F))),
              ],
            ],
            if (!running) ...[
              if (s.lastError != null &&
                  (s.status == StatusType.failed.name ||
                      s.status == StatusType.error.name)) ...[
                const SizedBox(height: 4),
                Text('Hata: ${s.lastError}',
                    style: const TextStyle(color: Color(0xFFD32F2F))),
                const SizedBox(height: 8),
              ],
              if (s.receipt != null)
                _ReceiptTable(
                  data: s.receipt!,
                  showErrors: s.showErrors,
                  onChanged: (updated) {
                    s.receipt = updated;
                    // clear errors as user edits
                    if (s.showErrors) {
                      final errs = _collectErrors(updated);
                      if (errs.isEmpty) {
                        setState(() => s.showErrors = false);
                      }
                    }
                    final encoded =
                        const JsonEncoder.withIndent('  ').convert(updated);
                    s.controller?.text = encoded;
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    s.lastError ?? 'Fiş datası okunamadı.',
                    style: TextStyle(
                      color: context.colorScheme.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

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
        put('İşlem Tarihi',
            '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}');
      } catch (_) {
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
          .whereType<Map>()
          .map((p) => _localizeProduct(Map<String, dynamic>.from(p)))
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

    put('businessName',
        source['Şirket Adı'] ?? source['isletmeAdi'] ?? source['firmaAdi']);
    put('receiptNumber',
        source['Fiş No'] ?? source['fisNumarasi'] ?? source['fisNo']);
    put('transactionDate', source['İşlem Tarihi'] ?? source['islemTarihi']);
    put('vatAmount', source['KDV Tutarı'] ?? source['kdvTutari']);
    put('vatRate', source['KDV Oranı (%)'] ?? source['kdvOrani']);
    put('totalAmount', source['Toplam Tutar'] ?? source['toplamTutar']);
    put('paymentType',
        source['Ödeme Türü'] ?? source['Ödeme Tipi'] ?? source['odemeTipi']);
    put('transactionType',
        source['İşlem Türü'] ?? source['İşlem Tipi'] ?? source['islemTipi']);

    final urunler = source['Ürünler'] ?? source['urunler'];
    if (urunler is List) {
      final products = urunler
          .whereType<Map>()
          .map((p) => _delocalizeProduct(Map<String, dynamic>.from(p)))
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

// ─────────────────────────────────────────────────────────────────────────────
// _ItemState
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Receipt table widget  (editable)
// ─────────────────────────────────────────────────────────────────────────────

/// Called whenever the user edits any field.  [updated] is the full, mutated
/// receipt map using the same Turkish localized keys as [data].
typedef ReceiptChangedCallback = void Function(Map<String, dynamic> updated);

class _ReceiptTable extends StatefulWidget {
  const _ReceiptTable(
      {required this.data, this.onChanged, this.showErrors = false});

  final Map<String, dynamic> data;
  final ReceiptChangedCallback? onChanged;
  final bool showErrors;

  @override
  State<_ReceiptTable> createState() => _ReceiptTableState();
}

class _ReceiptTableState extends State<_ReceiptTable> {
  // ── scalar field controllers ──────────────────────────────────────────────
  late final TextEditingController _businessName;
  late final TextEditingController _date;
  late final TextEditingController _receiptNo;
  late final TextEditingController _transType;
  late final TextEditingController _paymentType;
  late final TextEditingController _vatRate;
  late final TextEditingController _vat;
  late final TextEditingController _total;

  // ── working copy of the data map (mutated on every edit) ─────────────────
  late Map<String, dynamic> _current;

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _current = Map<String, dynamic>.from(widget.data);
    _initControllers();
  }

  void _initControllers() {
    _businessName = TextEditingController(
        text:
            _pick<String>(['Şirket Adı', 'businessName', 'companyName']) ?? '');
    _date = TextEditingController(
        text: _pick<String>(['İşlem Tarihi', 'transactionDate']) ?? '');
    _receiptNo = TextEditingController(
        text: _pick<String>(['Fiş No', 'receiptNumber']) ?? '');

    _transType = TextEditingController(
        text: _fmt(
            _pick<dynamic>(['İşlem Türü', 'İşlem Tipi', 'transactionType'])));
    _paymentType = TextEditingController(
        text: _pick<String>(['Ödeme Türü', 'Ödeme Tipi', 'paymentType']) ?? '');
    _vatRate = TextEditingController(
        text: _fmt(_pick<dynamic>(['KDV Oranı (%)', 'vatRate'])));

    _vat = TextEditingController(
        text: _fmt(_pick<dynamic>(['KDV Tutarı', 'kdvAmount', 'vatAmount'])));
    _total = TextEditingController(
        text: _fmt(_pick<dynamic>(['Toplam Tutar', 'totalAmount'])));

    // Attach listeners for all editable scalar controllers
    for (final ctrl in [
      _businessName,
      _date,
      _receiptNo,
      _transType,
      _paymentType,
      _vatRate,
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
      _vat,
      _total
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Change propagation
  // ─────────────────────────────────────────────────────────────────────────
  void _onScalarChanged() {
    _current['Şirket Adı'] = _businessName.text;
    _current['İşlem Tarihi'] = _date.text;
    _current['Fiş No'] = _receiptNo.text;
    _current['İşlem Tipi'] = _transType.text;
    _current['Ödeme Tipi'] = _paymentType.text;
    _current['KDV Oranı (%)'] = _vatRate.text;
    _current['KDV Tutarı'] = _vat.text;
    _current['Toplam Tutar'] = _total.text;
    // Remove old English keys that may have come from the backend
    for (final k in [
      'businessName',
      'companyName',
      'transactionDate',
      'receiptNumber',
      'transactionType',
      'paymentType',
      'kdvAmount',
      'vatAmount',
      'vatRate',
      'totalAmount'
    ]) {
      _current.remove(k);
    }
    widget.onChanged?.call(Map<String, dynamic>.from(_current));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns an error string if validation fails (only when showErrors is on).
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

  InputDecoration _dec(String hint, {String? errorText}) => InputDecoration(
        hintText: hint,
        errorText: errorText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: errorText != null
              ? const BorderSide(color: Color(0xFFD32F2F), width: 1.5)
              : BorderSide.none,
        ),
        filled: false,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final highlightStyle = context.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      color: context.colorScheme.primary,
    );

    // ── scalar rows (text-only) ───────────────────────────────────────────
    // İşlem Türü, Ödeme Türü, KDV Oranı are rendered as dropdowns below.
    final scalarRows = <({
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
        label: 'KDV Oranı (%)',
        ctrl: _vatRate,
        highlight: false,
        readOnly: false,
        err: _errorOf(_vatRate, numeric: true)
      ),
    ];

    // Reusable row padding
    const _rowPad = EdgeInsets.symmetric(horizontal: 14, vertical: 8);
    const _divider = Divider(height: 1);

    // Helper: builds the label+TextField row used for text fields
    Widget textRow(int i) => Padding(
          padding: _rowPad,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: 110,
                  child: Text(scalarRows[i].label, style: labelStyle),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: scalarRows[i].ctrl,
                  textAlign: TextAlign.right,
                  readOnly: scalarRows[i].readOnly,
                  style: scalarRows[i].highlight
                      ? highlightStyle
                      : context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scalarRows[i].readOnly
                              ? context.colorScheme.onSurfaceVariant
                              : null,
                        ),
                  decoration: _dec('', errorText: scalarRows[i].err).copyWith(
                    fillColor: scalarRows[i].readOnly
                        ? context.colorScheme.surfaceContainerHighest
                        : null,
                    hintText:
                        scalarRows[i].readOnly ? 'Otomatik hesaplanır' : '',
                  ),
                ),
              ),
            ],
          ),
        );

    final extras = _pick<Map>(['Diğer Alanlar']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main fields ─────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              for (int i = 0; i < scalarRows.length; i++) ...[
                textRow(i),
                if (i < scalarRows.length - 1) _divider,
              ],
            ],
          ),
        ),

        // ── Extra fields (read-only for now) ──────────────────────────────
        if (extras != null && extras.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Diğer Alanlar',
            style: context.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: Column(
              children: extras.entries.toList().asMap().entries.map((e) {
                final i = e.key;
                final kv = e.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 110,
                              child:
                                  Text(kv.key.toString(), style: labelStyle)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              kv.value?.toString() ?? '—',
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < extras.entries.length - 1)
                      Divider(
                          height: 1, color: context.colorScheme.outlineVariant),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
