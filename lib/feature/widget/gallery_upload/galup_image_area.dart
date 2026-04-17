part of '../../page/gallery_upload_page.dart';

final class _GalleryUploadImageArea extends StatelessWidget {
  const _GalleryUploadImageArea({required this.img});

  final Image? img;

  @override
  Widget build(BuildContext context) {
    if (img != null) {
      return Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: img,
        ),
      );
    } else {
      return const Expanded(
        child: Center(child: Text('Önizleme için bir fotoğraf seçin')),
      );
    }
  }
}
