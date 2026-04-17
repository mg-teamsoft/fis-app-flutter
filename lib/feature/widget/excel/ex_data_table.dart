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
        columns: const [
          DataColumn(label: Text('Dosya Adı')),
          DataColumn(label: Text('Sayfa (Ay/Yıl)')),
          DataColumn(label: Text('İşlemler')),
        ],
        rows: rows.map((r) {
          final isBusy = busy.contains(r.idOrKey);
          return DataRow(
            cells: [
              DataCell(Text(r.fileName)),
              DataCell(Text(r.sheetName)),
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
