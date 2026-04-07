part of '../page/receipt_page.dart';

class _ReceiptView extends StatelessWidget {
  const _ReceiptView({
    required this.pickMultiGallery,
    required this.captureCamera,
    required this.openManualForm,
    required this.processSelected,
    required this.picked,
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
  final Map<String, Future<Uint8List>> bytesCache;
  final String processButtonLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReceiptTopHead(
              pickMultiGallery: pickMultiGallery,
              captureCamera: captureCamera,
              openManualForm: openManualForm,
            ),
            _ReceiptMidHead(picked: picked, bytesCache: bytesCache),
            _ReceiptBottomHead(
              picked: picked,
              bytesCache: bytesCache,
              processButtonLabel: processButtonLabel,
              processSelected: processSelected,
              size: size,
            ),
          ],
        ),
      ),
    );
  }
}
