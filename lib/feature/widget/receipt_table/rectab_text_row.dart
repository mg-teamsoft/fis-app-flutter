part of '../../page/receipt_table_page.dart';

class _ReceiptTableTextRow extends StatelessWidget {
  const _ReceiptTableTextRow({
    required this.row,
    required this.scalarRows,
  });

  final int row;
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
              width: ThemeSize.avatarXL,
              child: ThemeTypography.labelMedium(
                context,
                scalarRows[row].hasError
                    ? '⚠️ ${scalarRows[row].label}'
                    : scalarRows[row].label,
                color: scalarRows[row].hasError
                    ? context.theme.error
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: ThemeSize.spacingS),
          Expanded(
            child: TextField(
              controller: scalarRows[row].ctrl,
              textAlign: TextAlign.right,
              readOnly: scalarRows[row].readOnly,
              style: scalarRows[row].highlight
                  ? context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.primary,
                    )
                  : context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scalarRows[row].readOnly
                          ? context.colorScheme.onSurfaceVariant
                          : null,
                    ),
              decoration: _inputDecoration(
                context,
                scalarRows[row].hasError ? '⚠️' : '',
                isError: scalarRows[row].hasError,
                errorText: scalarRows[row].err,
              ).copyWith(
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
