part of '../../page/receipt_gallery_page.dart';

final class _ReceiptGalleryContent extends StatelessWidget {
  const _ReceiptGalleryContent({
    required this.isLoadingInitial,
    required this.error,
    required this.allReceipts,
    required this.loadReceipts,
    required this.openDetails,
  });

  final bool isLoadingInitial;
  final Object? error;
  final List<ModelReceipt> allReceipts;
  final Future<void> Function() loadReceipts;
  final void Function(ModelReceipt) openDetails;

  @override
  Widget build(BuildContext context) {
    if (isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      return _GalleryError(
        message: 'Fişler yüklenirken bir hata oluştu.',
        details: error!.toString(),
        onRetry: loadReceipts,
      );
    } else if (allReceipts.isEmpty) {
      return const _GalleryEmptyState();
    } else {
      return _ReceiptsList(
        receipts: allReceipts,
        onOpenDetails: openDetails,
      );
    }
  }
}
