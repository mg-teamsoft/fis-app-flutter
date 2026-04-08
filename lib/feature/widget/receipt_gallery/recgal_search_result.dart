part of '../../page/receipt_gallery_page.dart';

final class _ReceiptGallerySearchResult extends StatelessWidget {
  const _ReceiptGallerySearchResult({
    required this.isLoadingInitial,
    required this.error,
    required this.allReceipts,
    required this.loadReceipts,
    required this.isSearching,
    required this.openDetails,
    required this.filteredReceipts,
    required this.showOverlay,
  });

  final bool isLoadingInitial;
  final Object? error;
  final List<ModelReceipt> allReceipts;
  final Future<void> Function() loadReceipts;
  final bool isSearching;
  final Future<void> Function(ModelReceipt) openDetails;
  final List<ModelReceipt> filteredReceipts;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // Base List
          _ReceiptGalleryContent(
            isLoadingInitial: isLoadingInitial,
            error: error,
            allReceipts: allReceipts,
            loadReceipts: loadReceipts,
            openDetails: openDetails,
          ),

          // Blur Overlay & Search Results
          if (showOverlay)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: ColoredBox(
                    color: context.colorScheme.surface.withValues(alpha: 0.4),
                    child: isSearching
                        ? const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _ReceiptGalleryBuildSearchResult(
                            theme: context.themedata,
                            openDetails: openDetails,
                            filteredReceipts: filteredReceipts,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
