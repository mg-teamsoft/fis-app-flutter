part of '../../page/receipt_result.dart';

class _ReceiptResultEditorArea extends StatefulWidget {
  const _ReceiptResultEditorArea({
    required this.submitted,
    required this.state,
    required this.errors,
  });

  final bool submitted;
  final _ItemState state;
  final List<String> Function(Map<String, dynamic>?) errors;

  @override
  State<_ReceiptResultEditorArea> createState() =>
      __ReceiptResultEditorAreaState();
}

class __ReceiptResultEditorAreaState extends State<_ReceiptResultEditorArea> {
  bool get running =>
      widget.state.active &&
      (widget.state.status != StatusType.done.name &&
          widget.state.status != StatusType.failed.name &&
          widget.state.status != StatusType.error.name);

  String get countdownText =>
      running ? 'Tekrar sorgu: ${widget.state.countdown}s' : '';

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: ThemeRadius.circular12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (running) ...[
              Text(countdownText, style: context.textTheme.bodyMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (10 - widget.state.countdown).clamp(0, 10) / 10.0,
                minHeight: 6,
              ),
              if (widget.state.lastError != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Hata: ${widget.state.lastError}',
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
            if (!running) ...[
              if (widget.state.lastError != null &&
                  (widget.state.status == StatusType.failed.name ||
                      widget.state.status == StatusType.error.name)) ...[
                const SizedBox(height: 4),
                Text(
                  'Hata: ${widget.state.lastError}',
                  style: const TextStyle(color: Color(0xFFD32F2F)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              if (widget.state.receipt != null)
                PageReceiptTable(
                  data: widget.state.receipt!,
                  showErrors: widget.state.showErrors,
                  onChanged: (updated) {
                    widget.state.receipt = updated;
                    // clear errors as user edits
                    if (widget.state.showErrors) {
                      final errs = widget.errors(updated);
                      if (errs.isEmpty) {
                        setState(() => widget.state.showErrors = false);
                      }
                    }
                    final encoded =
                        const JsonEncoder.withIndent('  ').convert(updated);
                    widget.state.controller?.text = encoded;
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    widget.state.lastError ?? 'Fiş datası okunamadı.',
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
}
