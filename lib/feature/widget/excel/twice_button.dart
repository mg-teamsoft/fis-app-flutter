part of '../../page/excel.dart';

class _ExcelTwiceButton extends StatelessWidget {
  const _ExcelTwiceButton({
    required this.isBusy,
    required this.open,
    required this.download,
    required this.entry,
  });

  final bool isBusy;
  final Future<void> Function(ExcelFileEntry) open;
  final Future<void> Function(ExcelFileEntry) download;
  final ExcelFileEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: isBusy ? null : () => open(entry),
          icon: const Icon(Icons.open_in_new),
          label: Text(
            isBusy ? 'Açılıyor...' : 'Aç',
            style: context.textTheme.bodySmall,
          ),
        ),
        const SizedBox(
          width: ThemeSize.spacingS,
        ),
        OutlinedButton.icon(
          onPressed: isBusy ? null : () => download(entry),
          icon: const Icon(Icons.download),
          label: Text(
            isBusy ? 'İndiriliyor...' : 'İndir',
            style: context.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
