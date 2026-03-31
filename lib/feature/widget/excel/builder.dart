part of '../../page/excel.dart';

class _ExcelBuilder extends StatelessWidget {
  const _ExcelBuilder(
      {required this.future,
      required this.busy,
      required this.open,
      required this.download});

  final Future<List<ExcelFileEntry>> future;
  final Set<String> busy;
  final Future<void> Function(ExcelFileEntry) open;
  final Future<void> Function(ExcelFileEntry) download;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<ExcelFileEntry>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }
          final rows = snap.data ?? const <ExcelFileEntry>[];
          if (rows.isEmpty) {
            return const Center(child: Text('Kayıtlı Excel bulunamadı.'));
          }

          return _ExcelDataTable(
            rows: rows,
            busy: busy,
            open: open,
            download: download,
          );
        },
      ),
    );
  }
}
