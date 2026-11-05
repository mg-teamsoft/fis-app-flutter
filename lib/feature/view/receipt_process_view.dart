part of '../page/receipt_process_page.dart';

class _ReceiptProcessView extends StatelessWidget {
  const _ReceiptProcessView({
    required this.size,
    required this.files,
    required this.processing,
    required this.bytesCache,
    required this.process,
    required this.previewImage,
    required this.removeImage,
  });

  final List<XFile> files;
  final bool processing;
  final Map<String, Future<Uint8List>> bytesCache;
  final VoidCallback process;
  final Size size;
  final ValueChanged<XFile> previewImage;
  final ValueChanged<XFile> removeImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const ThemePadding.all16(),
      child: Column(
        children: [
          ThemeTypography.titleMedium(context, 'Görselleri kontrol edin'),
          const SizedBox(height: 8),
          const Text(
            'Büyütmek için görsele dokunun. Hatalı kırpılan görselleri çıkarıp yeniden seçebilirsiniz.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _ReceiptProcessList(
            files: files,
            processing: processing,
            bytesCache: bytesCache,
            previewImage: previewImage,
            removeImage: removeImage,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          _ReceiptProcessFilledButton(
            processing: processing,
            process: files.isEmpty ? null : process,
          ),
        ],
      ),
    );
  }
}
