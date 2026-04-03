part of '../../page/receipt.dart';

class _ReceiptTopHead extends StatelessWidget {
  const _ReceiptTopHead({
    required this.pickMultiGallery,
    required this.captureCamera,
    required this.openManualForm,
  });

  final VoidCallback pickMultiGallery;
  final VoidCallback captureCamera;
  final VoidCallback openManualForm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        BuildActionButton(
          onPressed: pickMultiGallery,
          icon: Icons.photo_library_outlined,
          label: 'Galeriden Resim Seç',
        ),
        const SizedBox(height: 12),
        BuildActionButton(
          onPressed: captureCamera,
          icon: Icons.photo_camera_outlined,
          label: 'Kamerayla Çek',
        ),
        const SizedBox(height: 12),
        BuildActionButton(
          onPressed: openManualForm,
          icon: Icons.edit_note,
          label: 'Manuel Fatura Ekle',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
