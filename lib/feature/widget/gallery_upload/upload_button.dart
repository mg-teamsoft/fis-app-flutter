part of '../../page/gallery_upload.dart';

final class _GalleryUploadButton extends StatelessWidget {
  const _GalleryUploadButton({
    required this.uploading,
    required this.picked,
    required this.upload,
  });

  final bool uploading;
  final XFile? picked;
  final Future<void> Function() upload;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: (picked == null || uploading) ? null : upload,
        icon: uploading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.cloud_upload,
                size: ThemeSize.iconMedium,
                color: context.colorScheme.onSurface,
              ),
        label: Text(
          uploading ? 'Yükleniyor...' : 'Yükle',
          style: context.textTheme.titleMedium,
        ),
      ),
    );
  }
}
