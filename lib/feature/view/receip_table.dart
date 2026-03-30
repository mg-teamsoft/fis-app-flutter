part of '../page/receipt_table.dart';

class _ReceiptTableView extends StatelessWidget {
  const _ReceiptTableView({
    required this.scalarRows,
    required this.extras,
  });

  final List<
      ({
        String label,
        TextEditingController ctrl,
        bool highlight,
        bool readOnly,
        String? err,
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
