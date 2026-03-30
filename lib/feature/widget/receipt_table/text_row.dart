part of '../../page/receipt_table.dart';

class _ReceiptTableTextRow extends StatelessWidget {
  const _ReceiptTableTextRow({
    required this.row,
    required this.scalarRows,
  });

  final int row;
  final List<
      ({
        String label,
        TextEditingController ctrl,
        bool highlight,
        bool readOnly,
        String? err,
      })> scalarRows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ThemePadding.horizontalSymmetricFree(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 110,
              child: Text(
                scalarRows[row].label,
                style: context.textTheme.labelMedium,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: scalarRows[row].ctrl,
              textAlign: TextAlign.right,
              readOnly: scalarRows[row].readOnly,
              style: scalarRows[row].highlight
                  ? context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: context.colorScheme.primary,
                    )
                  : context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scalarRows[row].readOnly
                          ? context.colorScheme.onSurfaceVariant
                          : null,
                    ),
              decoration: _input_Decoration('', errorText: scalarRows[row].err)
                  .copyWith(
                fillColor: scalarRows[row].readOnly
                    ? context.colorScheme.surfaceContainerHighest
                    : null,
                hintText: scalarRows[row].readOnly ? 'Otomatik hesaplanır' : '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
