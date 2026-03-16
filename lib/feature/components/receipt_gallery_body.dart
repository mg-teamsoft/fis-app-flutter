part of '../../page/receipt_gallery.dart';

class _BodyReceiptGallery extends StatelessWidget {
  const _BodyReceiptGallery(
      {required this.scrollController,
      required this.onRetry,
      required this.onOpenDetails,
      required this.capitalize,
      required this.onSearchAction, required this.onFilter, required this.state,});

  final ScrollController scrollController;
final ReceiptGalleryPageState state;
  final VoidCallback onRetry;
  final void Function(String) onSearchAction;
  final void Function(String?) onFilter;
  final void Function(ReceiptSummary) onOpenDetails;
  final String Function(String) capitalize;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: scrollController,
        padding: ThemePadding.all10(),
        child: Column(

          children: [
            _ReceiptGalleryHeader(
              onSearchChanged: onSearchAction,
              onFilter: onFilter,
            ),

            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    // 1. Yüklenme Durumu
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Hata Durumu (Es geçmediğimiz yer burası paşam)
    if (state.errorMessage.isNotEmpty) {
      return _ReceiptGalleryError(
        message: 'Fişler yüklenirken bir hata oluştu.',
        details: state.errorMessage,
        onRetry: onRetry,
      );
    }

    // 3. Boş Liste Durumu
    if (state.filteredReceipts.isEmpty) return const _ReceiptGalleyEmptyState();

    // 4. Başarılı Liste Durumu
    return _ReceiptGalleryList(
      receipts: state.filteredReceipts,
      onOpenDetails: onOpenDetails,
      capitalize: capitalize,
    );
  }
}
