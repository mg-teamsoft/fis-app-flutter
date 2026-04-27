part of '../page/receipt_table_page.dart';

class _ReceiptTableView extends StatelessWidget {
  const _ReceiptTableView({
    required this.scalarRows,
    required this.extras,
  });

  final List<
      ({
        TextEditingController ctrl,
        String key,
        String? err,
        bool highlight,
        String label,
        bool hasError,
        bool readOnly
      })> scalarRows;
  final Map<String, dynamic>? extras;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main fields ─────────────────────────────────────────────────────
        _ReceiptTableMainField(scalarRows: scalarRows),

        // ── Extra fields (read-only for now) ──────────────────────────────
        _ReceiptTableExtraField(extras: extras),
      ],
    );
  }
}
