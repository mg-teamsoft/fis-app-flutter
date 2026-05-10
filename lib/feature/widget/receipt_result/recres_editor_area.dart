part of '../../page/receipt_result_page.dart';

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
        padding: const ThemePadding.all10(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (running) ...[
              ThemeTypography.bodyMedium(
                context,
                countdownText,
                color: context.colorScheme.onSurface,
              ),
              const SizedBox(height: ThemeSize.spacingS),
              LinearProgressIndicator(
                value: (10 - widget.state.countdown).clamp(0, 10) / 10.0,
                minHeight: 6,
              ),
              if (widget.state.lastError != null) ...[
                const SizedBox(height: ThemeSize.spacingS),
                ThemeTypography.bodyMedium(
                  context,
                  'Hata: ${widget.state.lastError}',
                  color: context.theme.error,
                ),
              ],
            ],
            if (!running) ...[
              if (widget.state.lastError != null &&
                  (widget.state.status == StatusType.failed.name ||
                      widget.state.status == StatusType.error.name)) ...[
                const SizedBox(height: ThemeSize.spacingS),
                ThemeTypography.bodyMedium(
                  context,
                  'Hata: ${widget.state.lastError}',
                  color: context.theme.error,
                ),
                const SizedBox(height: ThemeSize.spacingS),
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
                    final controller = widget.state.controller;
                    if (controller != null) {
                      controller.value = TextEditingValue(
                        text: encoded,
                        selection: TextSelection.collapsed(
                          offset: encoded.length,
                        ),
                      );
                    }
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ThemeTypography.bodyMedium(
                    context,
                    widget.state.lastError ?? 'Fiş datası okunamadı.',
                    color: context.theme.error,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
