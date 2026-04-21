part of '../page/receipt_gallery_page.dart';

class _ReceiptGalleryView extends StatelessWidget {
  const _ReceiptGalleryView({
    required this.loadReceipts,
    required this.showOverlay,
    required this.openDetails,
    required this.fuzzyMatch,
    required this.pickDateRange,
    required this.clearDateRange,
    required this.customerItems,
    required this.selectedCustomerId,
    required this.appliedCustomerId,
    required this.isLoadingCustomers,
    required this.onCustomerChanged,
    required this.applyCustomerSelection,
    required this.onSearchChanged,
    required this.receiptApiService,
    required this.isLoadingInitial,
    required this.allReceipts,
    required this.searchController,
    required this.scrollController,
    required this.searchQuery,
    required this.isSearching,
    required this.filteredReceipts,
    this.error,
    this.debounce,
    this.selectedDateRange,
  });

  final ReceiptApiService receiptApiService;
  final bool isLoadingInitial;
  final String? error;
  final List<ModelReceipt> allReceipts;
  final bool showOverlay;

  // Search state
  final TextEditingController searchController;
  final ScrollController scrollController;
  final String searchQuery;
  final bool isSearching;
  final List<ModelReceipt> filteredReceipts;
  final Timer? debounce;
  final DateTimeRange? selectedDateRange;
  final List<CustomerListItemDto> customerItems;
  final String? selectedCustomerId;
  final String? appliedCustomerId;
  final bool isLoadingCustomers;

  final Future<void> Function() pickDateRange;
  final void Function() clearDateRange;
  final void Function(String?) onCustomerChanged;
  final Future<void> Function() applyCustomerSelection;
  final void Function(String)? onSearchChanged;
  final Future<void> Function(ModelReceipt) openDetails;
  final bool Function(String, String) fuzzyMatch;
  final Future<void> Function() loadReceipts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        const SizedBox(height: ThemeSize.spacingXs),
        Align(
          child: ThemeTypography.h4(
            context,
            'Fişler',
            weight: FontWeight.w900,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: ThemeSize.spacingM),
        _ReceiptGallerySearchBar(
          searchController: searchController,
          searchQuery: searchQuery,
          isSearching: isSearching,
          filteredReceipts: filteredReceipts,
          selectedDateRange: selectedDateRange,
          customerItems: customerItems,
          selectedCustomerId: selectedCustomerId,
          appliedCustomerId: appliedCustomerId,
          isLoadingCustomers: isLoadingCustomers,
          onSearchChanged: onSearchChanged,
          pickDateRange: pickDateRange,
          clearDateRange: clearDateRange,
          onCustomerChanged: onCustomerChanged,
          applyCustomerSelection: applyCustomerSelection,
        ),
        _ReceiptGallerySearchResult(
          isLoadingInitial: isLoadingInitial,
          error: error,
          allReceipts: allReceipts,
          loadReceipts: loadReceipts,
          isSearching: isSearching,
          openDetails: openDetails,
          filteredReceipts: filteredReceipts,
          showOverlay: showOverlay,
        ),
      ],
    );
  }
}
