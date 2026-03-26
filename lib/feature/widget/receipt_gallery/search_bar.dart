part of '../../page/receipt_gallery.dart';

final class _ReceiptGallerySearchBar extends StatelessWidget {
  const _ReceiptGallerySearchBar({
    required this.searchController,
    required this.searchQuery,
    required this.isSearching,
    required this.filteredReceipts,
    required this.selectedDateRange,
    required this.onSearchChanged,
    required this.pickDateRange,
    required this.clearDateRange,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final bool isSearching;
  final List<ModelReceipt> filteredReceipts;

  final DateTimeRange? selectedDateRange;
  final void Function(String)? onSearchChanged;
  final Future<void> Function() pickDateRange;
  final void Function() clearDateRange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Fiş ara (şirket adına göre)...',
              prefixIcon: Icon(
                Icons.search,
                color: context.colorScheme.onPrimary,
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
          Row(
            children: [
              ActionChip(
                color: WidgetStatePropertyAll(context.colorScheme.secondary),
                avatar: Icon(Icons.date_range,
                    size: ThemeSize.iconMedium,
                    color: context.colorScheme.onSecondary),
                label: Text(
                  selectedDateRange == null
                      ? 'Tarih Aralığı Seç'
                      : '${DateFormat('d MMM', 'tr_TR').format(selectedDateRange!.start)} - ${DateFormat('d MMM', 'tr_TR').format(selectedDateRange!.end)}',
                  style: ThemeTypography.bodyLarge(
                    context,
                    '',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSecondary),
                  ).style,
                ),
                onPressed: pickDateRange,
              ),
              if (selectedDateRange != null) ...[
                const SizedBox(width: 8),
                ActionChip(
                  avatar: Icon(Icons.clear,
                      size: ThemeSize.iconMedium,
                      color: context.colorScheme.onSurface),
                  label: Text(
                    'Temizle',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onPrimary),
                  ),
                  onPressed: clearDateRange,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
