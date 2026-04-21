part of '../../page/receipt_gallery_page.dart';

final class _ReceiptGalleryHeader extends StatelessWidget {
  const _ReceiptGalleryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: ThemeTypography.h4(
        context,
        'Fişler',
        color: context.colorScheme.onSurface.withValues(alpha: 0.8),
        textAlign: TextAlign.center,
      ),
    );
  }
}
