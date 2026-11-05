part of '../page/receipt_page.dart';

class _ReceiptView extends StatelessWidget {
  const _ReceiptView({
    required this.pickMultiGallery,
    required this.captureCamera,
    required this.openManualForm,
    required this.processSelected,
    required this.picked,
    required this.removeSelected,
    required this.bytesCache,
    required this.processButtonLabel,
    required this.size,
  });

  final Size size;
  final Future<void> Function() pickMultiGallery;
  final Future<void> Function() captureCamera;
  final void Function() openManualForm;
  final void Function() processSelected;
  final List<XFile> picked;
  final ValueChanged<XFile> removeSelected;
  final Map<String, Future<Uint8List>> bytesCache;
  final String processButtonLabel;

  @override
  Widget build(BuildContext context) {
    if (picked.isEmpty) {
      return SingleChildScrollView(
        padding: const ThemePadding.horizontalSymmetric(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const _ReceiptPhotoTips(),
            _ReceiptTopHead(
              pickMultiGallery: pickMultiGallery,
              captureCamera: captureCamera,
              openManualForm: openManualForm,
            ),
            ThemeTypography.bodyMedium(
              context,
              'Galerinizden fiş seçin veya kamerayla çekin.',
              color: context.colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }
    return Padding(
      padding: const ThemePadding.horizontalSymmetric(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReceiptTopHead(
            pickMultiGallery: pickMultiGallery,
            captureCamera: captureCamera,
            openManualForm: openManualForm,
          ),
          _ReceiptMidHead(
            picked: picked,
            bytesCache: bytesCache,
            removeSelected: removeSelected,
          ),
          _ReceiptBottomHead(
            picked: picked,
            bytesCache: bytesCache,
            processButtonLabel: processButtonLabel,
            processSelected: processSelected,
            size: size,
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
        ],
      ),
    );
  }
}
