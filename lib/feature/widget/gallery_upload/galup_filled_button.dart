part of '../../page/gallery_upload_page.dart';

final class _GalleryUploadFilledButton extends StatelessWidget {
  const _GalleryUploadFilledButton({
    required this.uploading,
    required this.pick,
  });

  final bool uploading;
  final Future<void> Function() pick;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: uploading ? null : pick,
      icon: const Icon(
        Icons.photo_library,
        size: ThemeSize.iconMedium,
      ),
      label: Text(
        'Galeriden Seç',
        style: context.textTheme.bodyMedium,
      ),
    );
  }
}
