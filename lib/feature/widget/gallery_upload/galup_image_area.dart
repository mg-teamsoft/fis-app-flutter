part of '../../page/gallery_upload_page.dart';

final class _GalleryUploadImageArea extends StatelessWidget {
  const _GalleryUploadImageArea({required this.img});

  final Image? img;

  @override
  Widget build(BuildContext context) {
    if (img != null) {
      return Expanded(
        child: ClipRRect(
          borderRadius: ThemeRadius.circular12,
          child: img,
        ),
      );
    } else {
      return Expanded(
        child: Center(
          child: ThemeTypography.bodyLarge(
            context,
            'Önizleme için bir fotoğraf seçin',
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
  }
}
