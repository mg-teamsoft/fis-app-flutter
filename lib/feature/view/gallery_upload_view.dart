part of '../page/gallery_upload_page.dart';

final class _GalleryUploadView extends StatelessWidget {
  const _GalleryUploadView({
    required this.picked,
    required this.uploading,
    required this.img,
    required this.pick,
    required this.upload,
  });

  final bool uploading;
  final XFile? picked;
  final Image? img;
  final Future<void> Function() pick;
  final Future<void> Function() upload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const ThemePadding.all16(),
      child: Column(
        children: [
          _GalleryUploadFilledButton(uploading: uploading, pick: pick),
          const SizedBox(height: ThemeSize.spacingM),
          _GalleryUploadImageArea(img: img),
          const SizedBox(height: ThemeSize.spacingM),
          _GalleryUploadButton(
            uploading: uploading,
            picked: picked,
            upload: upload,
          ),
        ],
      ),
    );
  }
}
