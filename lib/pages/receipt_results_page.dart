import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/receipt_flow_models.dart';
import '../services/job_service.dart';
import '../services/excel_service.dart';
import '../models/status_type.dart';

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

  /// Per-item UI + polling state
  final Map<String, _ItemState> _state = {}; // key: jobId

  Timer? _tick; // global 1s ticker for countdowns

  @override
  void initState() {
    super.initState();
    for (final it in widget.items) {
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
      // Expectation: JobService.getJob returns either:
      //   { status: "success", job: { status, receipt, ... } }
      //   or a flattened { status, receipt, ... }
      final resp = await _jobs.getJob(jobId);

      // Try to normalize the job object
      final Map<String, dynamic> jobObj =
          (resp['job'] is Map<String, dynamic>) ? resp['job'] : resp;

      s.status = (jobObj['status'] as String?) ?? s.status;
      final message = jobObj['message']?.toString();

      // Receipt may be a map or a JSON string; normalize then localize for the editor
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

      // If job is done, stop the countdown and prepare the editor text
      if (s.status == StatusType.done.name) {
        s.lastError = null;
        s.active = false;
        s.countdown = 0;
        s.receipt = localizedReceipt;

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

        // Prepare / update the editable text box content
        final editorText = (localizedReceipt != null)
            ? const JsonEncoder.withIndent('  ').convert(localizedReceipt)
            : s.lastError!;

        if (s.controller == null) {
          s.controller = TextEditingController(text: editorText);
        } else {
          s.controller!.text = editorText;
        }
      } else {
        // still running; keep showing progress
        s.active = true;
        s.lastError = message;
      }
    } catch (e) {
      // On error, keep it active but surface a toast-able message in UI
      s.lastError = e.toString();
    }

    if (mounted) setState(() {});
  }

  Future<void> _approveAll() async {
    if (_submitting) return; // already running
    setState(() {
      _submitting = true;
      _hasSuccessfulSubmission = null;
    });

    // Collect successes/failures
    int okCount = 0;
    int failCount = 0;
    final failures = <String>[];

    for (final entry in _state.entries) {
      final s = entry.value;
      // Only try if we have an editor with JSON content
      final ctrl = s.controller;
      if (ctrl == null) continue;

      // Skip still running / failed-without-json items
      if (s.status != StatusType.done.name) continue;

      try {
        // If editor contains "can not read receipt data", skip
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
        ? '✅ $okCount fiş Excel’e yazıldı'
        : '✅ $okCount yazıldı • ❌ $failCount başarısız\n${failures.join('\n')}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );

    setState(() {
      _submitting = false;
      _hasSuccessfulSubmission = okCount > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items.where((it) => it.jobId != null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sonuçlar')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final it = items[i];
                  final s = _state[it.jobId] ?? _ItemState(item: it); // safety
                  final wide = MediaQuery.of(context).size.width > 700;

                  final image = ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 1.0,
                      maxScale: 5.0,
                      child: Image.file(
                        File(it.file.path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );

                  final editor = _buildEditorArea(context, s);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: wide
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
                  );
                },
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: (_submitting || _hasSuccessfulSubmission != null)
                        ? null
                        : _approveAll,
                    icon: const Icon(Icons.check),
                    label: Text(
                      _submitting
                          ? "Gönderiliyor..."
                          : _hasSuccessfulSubmission != null
                              ? "İşlem Tamamlandı"
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

  Widget _buildEditorArea(BuildContext context, _ItemState s) {
    final theme = Theme.of(context);
    final surface =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);

    final running = s.active &&
        (s.status != StatusType.done.name &&
            s.status != StatusType.failed.name &&
            s.status != StatusType.error.name);
    final showReceiptText = !running;

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
              Text(countdownText, style: theme.textTheme.bodyMedium),
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
            if (showReceiptText) ...[
              const SizedBox(height: 4),
              if (s.lastError != null &&
                  (s.status == StatusType.failed.name ||
                      s.status == StatusType.error.name)) ...[
                Text('Hata: ${s.lastError}',
                    style: const TextStyle(color: Color(0xFFD32F2F))),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: s.controller ??
                    (s.controller = TextEditingController(
                      text: s.receipt != null
                          ? const JsonEncoder.withIndent('  ')
                              .convert(s.receipt)
                          : 'can not read receipt data',
                    )),
                maxLines: 18,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sonuç JSON (düzenlenebilir)',
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
    'kdvAmount',
    'totalAmount',
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
    put('İşlem Tarihi', raw['transactionDate']);
    put('Fiş No', raw['receiptNumber']);
    put('KDV Tutarı', raw['kdvAmount']);
    put('Toplam Tutar', raw['totalAmount']);
    put('Ödeme Tipi', raw['paymentType']);

    final transactionType = raw['transactionType'];
    if (transactionType is Map) {
      final typed = Map<String, dynamic>.from(transactionType);
      put('İşlem Tipi', typed['type'] ?? typed['name']);
      put('KDV Oranı (%)', typed['kdvRate']);
      final extra = Map<String, dynamic>.from(typed)
        ..remove('type')
        ..remove('name')
        ..remove('kdvRate');
      if (extra.isNotEmpty) {
        localized['Diğer Alanlar'] = extra;
      }
    } else if (transactionType != null) {
      put('İşlem Tipi', transactionType);
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
    put('kdvAmount', source['KDV Tutarı'] ?? source['kdvTutari']);
    put('totalAmount', source['Toplam Tutar'] ?? source['toplamTutar']);
    put('paymentType', source['Ödeme Tipi'] ?? source['odemeTipi']);

    final islemTipi = source['İşlem Tipi'] ?? source['islemTipi'];
    if (islemTipi is Map) {
      final map = Map<String, dynamic>.from(islemTipi);
      final normalizedIslem = <String, dynamic>{};
      if (map['tip'] != null) normalizedIslem['type'] = map['tip'];
      if (map['KDV Oranı (%)'] != null) {
        normalizedIslem['kdvRate'] = map['KDV Oranı (%)'];
      } else if (source['KDV Oranı (%)'] != null) {
        normalizedIslem['kdvRate'] = source['KDV Oranı (%)'];
      }
      final extra = Map<String, dynamic>.from(map)
        ..remove('tip')
        ..remove('KDV Oranı (%)');
      if (extra.isNotEmpty) {
        normalizedIslem.addAll(extra);
      }
      if (normalizedIslem.isNotEmpty) {
        normalized['transactionType'] = normalizedIslem;
      }
    } else if (islemTipi != null) {
      normalized['transactionType'] = {
        'type': islemTipi,
        if (source['KDV Oranı (%)'] != null) 'kdvRate': source['KDV Oranı (%)'],
      };
    } else if (source['KDV Oranı (%)'] != null) {
      normalized['transactionType'] = {'kdvRate': source['KDV Oranı (%)']};
    }

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

class _ItemState {
  _ItemState({required this.item});
  final SelectedItem item;

  /// Job status: 'pending' | StatusType.processing.name | StatusType.done.name | StatusType.failed.name …
  String status = StatusType.processing.name;

  /// 10-second countdown until next poll.
  int countdown = 10;

  /// Whether this item still needs polling (true until done/failed).
  bool active = true;

  /// Last backend error (if any).
  String? lastError;

  /// Original receipt payload from backend
  Map<String, dynamic>? rawReceipt;

  /// Localized receipt map (null if not available)
  Map<String, dynamic>? receipt;

  /// Editor controller (holds pretty JSON or message)
  TextEditingController? controller;
}
