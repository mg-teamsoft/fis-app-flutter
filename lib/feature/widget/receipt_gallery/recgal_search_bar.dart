part of '../../page/receipt_gallery_page.dart';

final class _ReceiptGallerySearchBar extends StatelessWidget {
  const _ReceiptGallerySearchBar({
    required this.searchController,
    required this.searchQuery,
    required this.isSearching,
    required this.filteredReceipts,
    required this.selectedDateRange,
    required this.customerItems,
    required this.selectedCustomerId,
    required this.appliedCustomerId,
    required this.isLoadingCustomers,
    required this.onSearchChanged,
    required this.pickDateRange,
    required this.clearDateRange,
    required this.onCustomerChanged,
    required this.applyCustomerSelection,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final bool isSearching;
  final List<ModelReceipt> filteredReceipts;

  final DateTimeRange? selectedDateRange;
  final List<CustomerListItemDto> customerItems;
  final String? selectedCustomerId;
  final String? appliedCustomerId;
  final bool isLoadingCustomers;
  final void Function(String)? onSearchChanged;
  final Future<void> Function() pickDateRange;
  final void Function() clearDateRange;
  final void Function(String?) onCustomerChanged;
  final Future<void> Function() applyCustomerSelection;

  @override
  Widget build(BuildContext context) {
    final shouldShowCustomerField = customerItems.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Fiş ara (İşletme, Tarih, Tutar)',
              prefixIconConstraints: const BoxConstraints(minWidth: 32),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 0.0), // Sağdaki boşluğu (right) 4 veya 0 yap
                child: Icon(
                  Icons.search,
                  color: context.colorScheme.onSurface,
                  size: 20, // İkonu biraz küçültmek de boşluk hissini azaltır
                ),
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: context.colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged?.call('');
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              filled: true,
              fillColor: context.colorScheme.surface.withValues(alpha: 0.2),
              border: OutlineInputBorder(
                borderRadius: ThemeRadius.circular12,
                borderSide: BorderSide(
                  color: context.colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                color: WidgetStatePropertyAll(context.colorScheme.secondary),
                avatar: Icon(
                  Icons.date_range,
                  size: ThemeSize.iconMedium,
                  color: context.colorScheme.onSecondary,
                ),
                label: Text(
                  selectedDateRange == null
                      ? 'Tarih Aralığı Seç'
                      : '${DateFormat('d MMM', 'tr_TR').format(selectedDateRange!.start)} - ${DateFormat('d MMM', 'tr_TR').format(selectedDateRange!.end)}',
                  style: ThemeTypography.bodyLarge(
                    context,
                    '',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSecondary,
                    ),
                  ).style,
                ),
                onPressed: pickDateRange,
              ),
              if (selectedDateRange != null) ...[
                ActionChip(
                  avatar: Icon(
                    Icons.clear,
                    size: ThemeSize.iconMedium,
                    color: context.colorScheme.onSurface,
                  ),
                  label: Text(
                    'Temizle',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                  onPressed: clearDateRange,
                ),
              ],
            ],
          ),
          if (isLoadingCustomers) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ],
          if (shouldShowCustomerField) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCustomerId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Müşteri',
                      filled: true,
                      fillColor: context.colorScheme.surface.withValues(
                        alpha: 0.2,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: ThemeRadius.circular12,
                        borderSide: BorderSide(
                          color: context.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                          width: 0.1,
                        ),
                      ),
                    ),
                    items: customerItems
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onCustomerChanged,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: selectedCustomerId == null
                        ? null
                        : applyCustomerSelection,
                    child: const Text('Seç'),
                  ),
                ),
              ],
            ),
            if (appliedCustomerId != null &&
                appliedCustomerId == selectedCustomerId)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Seçili müşteri aktif.',
                  style: ThemeTypography.bodySmall(
                    context,
                    '',
                    style: TextStyle(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ).style,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
