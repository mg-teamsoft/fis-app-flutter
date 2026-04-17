import 'dart:async';
import 'dart:ui';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/customer_service.dart';
import 'package:fis_app_flutter/app/services/receipt_api_service.dart';
import 'package:fis_app_flutter/core/capitalize.dart';
import 'package:fis_app_flutter/feature/model/receipt_model.dart';
import 'package:fis_app_flutter/feature/page/receipt_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part '../controller/receipt_gallery_controller.dart';
part '../view/receipt_gallery_view.dart';
part '../widget/receipt_gallery/recgal_build_search_result.dart';
part '../widget/receipt_gallery/recgal_content.dart';
part '../widget/receipt_gallery/recgal_empty_state.dart';
part '../widget/receipt_gallery/recgal_error.dart';
part '../widget/receipt_gallery/recgal_header.dart';
part '../widget/receipt_gallery/recgal_list.dart';
part '../widget/receipt_gallery/recgal_list_tile.dart';
part '../widget/receipt_gallery/recgal_month_group.dart';
part '../widget/receipt_gallery/recgal_search_bar.dart';
part '../widget/receipt_gallery/recgal_search_result.dart';

final class PageReceiptGallery extends StatefulWidget {
  const PageReceiptGallery({super.key});

  @override
  State<PageReceiptGallery> createState() => _PageReceiptGalleryState();
}

class _PageReceiptGalleryState extends State<PageReceiptGallery>
    with _ConnectionReceiptGallery {
  @override
  Widget build(BuildContext context) {
    return _ReceiptGalleryView(
      loadReceipts: _loadReceipts,
      showOverlay: _showOverlay,
      openDetails: _openDetails,
      fuzzyMatch: _fuzzyMatch,
      pickDateRange: _pickDateRange,
      clearDateRange: _clearDateRange,
      customerItems: _customerItems,
      selectedCustomerId: _selectedCustomerId,
      appliedCustomerId: _appliedCustomerId,
      isLoadingCustomers: _isLoadingCustomers,
      onCustomerChanged: _onCustomerChanged,
      applyCustomerSelection: _applyCustomerSelection,
      onSearchChanged: _onSearchChanged,
      receiptApiService: _receiptApiService,
      isLoadingInitial: _isLoadingInitial,
      allReceipts: _allReceipts,
      searchController: _searchController,
      scrollController: _scrollController,
      searchQuery: _searchQuery,
      isSearching: _isSearching,
      filteredReceipts: _filteredReceipts,
      error: _error,
      debounce: _debounce,
      selectedDateRange: _selectedDateRange,
    );
  }
}
