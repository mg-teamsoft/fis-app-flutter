part of '../../page/receipt_table_page.dart';

class _ReceiptTableMainField extends StatelessWidget {
  const _ReceiptTableMainField({
    required this.scalarRows,
  });

  final List<
      ({
        TextEditingController ctrl,
        String key,
        String? err,
        bool highlight,
        String label,
        bool readOnly
      })> scalarRows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (int i = 0; i < scalarRows.length; i++) ...[
            _ReceiptTableTextRow(row: i, scalarRows: scalarRows),
            if (i < scalarRows.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
