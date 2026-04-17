part of '../page/excel_page.dart';

class _ExcelView extends StatelessWidget {
  const _ExcelView({
    required this.scrollController,
    required this.busy,
    required this.open,
    required this.download,
    required this.future,
    required this.customerItems,
    required this.selectedCustomerId,
    required this.appliedCustomerId,
    required this.isLoadingCustomers,
    required this.onCustomerChanged,
    required this.applyCustomerSelection,
  });

  final Future<List<ExcelFileEntry>> future;
  final ScrollController scrollController;
  final Set<String> busy;
  final Future<void> Function(ExcelFileEntry) open;
  final Future<void> Function(ExcelFileEntry) download;
  final List<CustomerListItemDto> customerItems;
  final String? selectedCustomerId;
  final String? appliedCustomerId;
  final bool isLoadingCustomers;
  final void Function(String?) onCustomerChanged;
  final Future<void> Function() applyCustomerSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const ThemePadding.all16(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            child: ThemeTypography.h4(
              context,
              'Excel Dosyaları',
              color: context.colorScheme.onSurface,
            ),
          ),
          _ExcelCustomerPicker(
            customerItems: customerItems,
            selectedCustomerId: selectedCustomerId,
            appliedCustomerId: appliedCustomerId,
            isLoadingCustomers: isLoadingCustomers,
            onCustomerChanged: onCustomerChanged,
            applyCustomerSelection: applyCustomerSelection,
          ),
          const SizedBox(height: ThemeSize.spacingM),
          _ExcelBuilder(
            future: future,
            busy: busy,
            open: open,
            download: download,
          ),
        ],
      ),
    );
  }
}
