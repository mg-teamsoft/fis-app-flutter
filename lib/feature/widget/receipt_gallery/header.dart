part of '../../page/receipt_gallery.dart';

final class _ReceiptGalleryHeader extends StatelessWidget {
  const _ReceiptGalleryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Text(
        'Fişler',
        style: context.textTheme.headlineLarge?.copyWith(
          color: context.colorScheme.onPrimary.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
