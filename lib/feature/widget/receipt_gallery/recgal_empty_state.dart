part of '../../page/receipt_gallery_page.dart';

final class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const ThemePadding.all32(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long,
              size: ThemeSize.iconXL,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            ThemeTypography.titleMedium(
              context,
              'Henüz kayıtlı fiş bulunmuyor.',
              textAlign: TextAlign.center,
              color: context.theme.warning,
            ),
          ],
        ),
      ),
    );
  }
}
