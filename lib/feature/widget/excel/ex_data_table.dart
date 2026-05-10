part of '../../page/excel_page.dart';

class _ExcelDataTable extends StatelessWidget {
  const _ExcelDataTable({
    required this.rows,
    required this.busy,
    required this.open,
    required this.download,
  });

  final List<ExcelFileEntry> rows;
  final Set<String> busy;
  final Future<void> Function(ExcelFileEntry) open;
  final Future<void> Function(ExcelFileEntry) download;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
            label: ThemeTypography.bodyMedium(
              context,
              'Dosya Adı',
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          DataColumn(
            label: ThemeTypography.bodyMedium(
              context,
              'Sayfa (Ay/Yıl)',
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          DataColumn(
            label: ThemeTypography.bodyMedium(
              context,
              'İşlemler',
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        rows: rows.map((r) {
          final isBusy = busy.contains(r.idOrKey);
          return DataRow(
            cells: [
              DataCell(
                ThemeTypography.bodyMedium(
                  context,
                  r.fileName,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              DataCell(
                ThemeTypography.bodyMedium(
                  context,
                  r.sheetName,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              DataCell(
                _ExcelTwiceButton(
                  isBusy: isBusy,
                  open: open,
                  download: download,
                  entry: r,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
