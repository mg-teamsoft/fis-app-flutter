part of '../../page/excel_page.dart';

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
          label: ThemeTypography.bodyMedium(
            context,
            isBusy ? 'Açılıyor...' : 'Aç',
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(
          width: ThemeSize.spacingS,
        ),
        OutlinedButton.icon(
          onPressed: isBusy ? null : () => download(entry),
          icon: const Icon(Icons.download),
          label: ThemeTypography.bodyMedium(
            context,
            isBusy ? 'İndiriliyor...' : 'İndir',
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
