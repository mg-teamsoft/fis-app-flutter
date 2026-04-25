part of '../../page/excel_page.dart';

class _ExcelBuilder extends StatelessWidget {
  const _ExcelBuilder({
    required this.future,
    required this.busy,
    required this.open,
    required this.download,
  });

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
            return Center(
              child: ThemeTypography.bodyLarge(
                context,
                'Hata: ${snap.error}',
                color: context.theme.error,
                weight: FontWeight.w800,
              ),
            );
          }
          final rows = snap.data ?? const <ExcelFileEntry>[];
          if (rows.isEmpty) {
            return Center(
              child: ThemeTypography.bodyLarge(
                context,
                'Kayıtlı Excel bulunamadı.',
                color: context.colorScheme.onSurface,
                weight: FontWeight.w800,
              ),
            );
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
