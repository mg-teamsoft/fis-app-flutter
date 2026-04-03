part of '../page/receipt_process.dart';

class _ReceiptProcessView extends StatelessWidget {
  const _ReceiptProcessView({
    required this.size,
    required this.files,
    required this.processing,
    required this.bytesCache,
    required this.process,
  });

  final List<XFile> files;
  final bool processing;
  final Map<String, Future<Uint8List>> bytesCache;
  final VoidCallback process;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const ThemePadding.all16(),
      child: Column(
        children: [
          _ReceiptProcessList(
            files: files,
            processing: processing,
            bytesCache: bytesCache,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          _ReceiptProcessFilledButton(
            processing: processing,
            process: process,
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
        ],
      ),
    );
  }
}
