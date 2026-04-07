part of '../../page/receipt_gallery_page.dart';

final class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long,
              size: 56,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz kayıtlı fiş bulunmuyor.',
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
