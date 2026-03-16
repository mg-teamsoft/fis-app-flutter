part of '../../../page/receipt_gallery.dart';

class _ReceiptGalleyEmptyState extends StatelessWidget {
  const _ReceiptGalleyEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long,
                size: 56, color: context.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Henüz kayıtlı fiş bulunmuyor.',
              style: context.appTextTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    
  }
}