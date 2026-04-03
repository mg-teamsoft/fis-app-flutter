part of '../page/excel.dart';

class _ExcelView extends StatelessWidget {
  const _ExcelView({
    required this.scrollController,
    required this.busy,
    required this.open,
    required this.download,
    required this.future,
  });

  final Future<List<ExcelFileEntry>> future;
  final ScrollController scrollController;
  final Set<String> busy;
  final Future<void> Function(ExcelFileEntry) open;
  final Future<void> Function(ExcelFileEntry) download;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            child: Text(
              'Excel Dosyaları',
              style: context.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: ThemeSize.spacingM),
          _ExcelBuilder(
            future: future,
            busy: busy,
            open: open,
            download: download,
          ),
        ],
      ),
    );
  }
}
