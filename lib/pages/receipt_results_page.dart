import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/receipt_flow_models.dart';
import '../services/job_service.dart';
import '../services/excel_service.dart';

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

      // Receipt may be a map or a JSON string; normalize to Map for the editor
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

      // If job is done, stop the countdown and prepare the editor text
      if (s.status == 'done') {
        s.lastError = null;
        s.active = false;
        s.countdown = 0;
        s.receipt = asMap;

        final editorText = (asMap != null)
            ? const JsonEncoder.withIndent('  ').convert(asMap)
            : message ?? 'can not read receipt data';

        if (s.controller == null) {
          s.controller = TextEditingController(text: editorText);
        } else {
          s.controller!.text = editorText;
        }
      } else if (s.status == 'failed' || s.status == 'error') {
        s.lastError = message ?? 'İşleme sırasında hata oluştu.';
        s.active = false;
        s.countdown = 0;
        s.receipt = asMap;

        // Prepare / update the editable text box content
        final editorText = (asMap != null)
            ? const JsonEncoder.withIndent('  ').convert(asMap)
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
      if (s.status != 'done') continue;

      try {
        // If editor contains "can not read receipt data", skip
        final text = ctrl.text.trim();
        if (text.toLowerCase().contains('can not read receipt data')) {
          failCount++;
          failures.add('${s.item.jobId}: empty');
          continue;
        }

        final Map<String, dynamic> edited = json.decode(text);
        final ok = await _excel.pushReceipt(edited);
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
        (s.status != 'done' && s.status != 'failed' && s.status != 'error');
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
                  (s.status == 'failed' || s.status == 'error')) ...[
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
}

class _ItemState {
  _ItemState({required this.item});
  final SelectedItem item;

  /// Job status: 'pending' | 'processing' | 'done' | 'failed' …
  String status = 'processing';

  /// 10-second countdown until next poll.
  int countdown = 10;

  /// Whether this item still needs polling (true until done/failed).
  bool active = true;

  /// Last backend error (if any).
  String? lastError;

  /// Parsed receipt map (null if not available)
  Map<String, dynamic>? receipt;

  /// Editor controller (holds pretty JSON or message)
  TextEditingController? controller;
}
