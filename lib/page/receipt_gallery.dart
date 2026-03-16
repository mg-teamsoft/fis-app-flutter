import 'package:fis_app_flutter/models/receipt_summary.dart';
import 'package:fis_app_flutter/pages/receipt_detail_page.dart';
import 'package:fis_app_flutter/services/receipt_api_service.dart';
import 'package:fis_app_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part '../feature/view/receipt_gallery_mixin.dart';
part '../feature/components/receipt_gallery_body.dart';
part '../feature/widget/receipt_gallery/empty_state.dart';
part '../feature/widget/receipt_gallery/error.dart';
part '../feature/widget/receipt_gallery/list.dart';
part '../feature/widget/receipt_gallery/month_group.dart';
part '../feature/widget/receipt_gallery/list_tile.dart';
part '../feature/widget/receipt_gallery/header.dart';
part '../feature/widget/receipt_gallery/search_bar.dart';
part '../feature/widget/receipt_gallery/filter_section.dart';
part '../feature/view/receipt_gallery.dart';

class PageReceiptGallery extends StatefulWidget {
  const PageReceiptGallery({super.key});

  @override
  State<PageReceiptGallery> createState() => _PageReceiptGalleryState();
}

class _PageReceiptGalleryState extends State<PageReceiptGallery>
    with MixinReceiptGallery {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.brandPrimary,
      body: _BodyReceiptGallery(
        scrollController: _scrollController,
        state: _state,
        onRetry: _reload,
        onOpenDetails: _openDetails,
        capitalize: _capitalize,
        onSearchAction: _onSearchChanged,
        onFilter: _applyFilter,
      ),
    );
  }
}
