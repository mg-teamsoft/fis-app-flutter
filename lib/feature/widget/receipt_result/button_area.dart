part of '../../page/receipt_result.dart';

class _ReceiptResultButtonArea extends StatelessWidget {
  const _ReceiptResultButtonArea({
    required this.submitting,
    required this.state,
    required this.approveAll,
    this.hasSuccessfulSubmission,
  });

  final bool? hasSuccessfulSubmission;
  final bool submitting;
  final Map<String, _ItemState> state;
  final Future<void> Function() approveAll;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: (submitting || state.values.any((s) => s.active))
                ? null
                : approveAll,
            icon: const Icon(Icons.check),
            label: Text(
              submitting
                  ? 'Gönderiliyor...'
                  : state.values.any((s) => s.active)
                      ? 'İşleniyor...'
                      : "Onayla ve Excel'e Yaz",
            ),
          ),
          if (hasSuccessfulSubmission != null) ...[
            const SizedBox(height: ThemeSize.spacingS),
            FilledButton.icon(
              onPressed: () async {
                final route =
                    hasSuccessfulSubmission! ? '/excelFiles' : '/receipt';
                await Navigator.pushNamed(context, route);
              },
              icon: Icon(
                hasSuccessfulSubmission!
                    ? Icons.table_view
                    : Icons.receipt_long,
              ),
              label: Text(
                hasSuccessfulSubmission!
                    ? 'Excel Dosya Sayfasına Git'
                    : 'Başa Dön',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
