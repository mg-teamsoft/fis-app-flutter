part of '../../page/excel_page.dart';

class _ExcelCustomerPicker extends StatelessWidget {
  const _ExcelCustomerPicker({
    required this.customerItems,
    required this.selectedCustomerId,
    required this.appliedCustomerId,
    required this.isLoadingCustomers,
    required this.onCustomerChanged,
    required this.applyCustomerSelection,
  });

  final List<CustomerListItemDto> customerItems;
  final String? selectedCustomerId;
  final String? appliedCustomerId;
  final bool isLoadingCustomers;
  final void Function(String?) onCustomerChanged;
  final Future<void> Function() applyCustomerSelection;

  @override
  Widget build(BuildContext context) {
    if (!isLoadingCustomers && customerItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: ThemeSize.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoadingCustomers) const LinearProgressIndicator(minHeight: 2),
          if (customerItems.isNotEmpty) ...[
            const SizedBox(height: ThemeSize.spacingS),
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
                            child: ThemeTypography.bodyLarge(
                              context,
                              item.name,
                              color: context.colorScheme.onSurface,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onCustomerChanged,
                  ),
                ),
                const SizedBox(width: ThemeSize.spacingS),
                SizedBox(
                  height: ThemeSize.buttonHeightLarge,
                  child: FilledButton(
                    onPressed: selectedCustomerId == null
                        ? null
                        : applyCustomerSelection,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                    ),
                    child: ThemeTypography.bodyLarge(
                      context,
                      'Seç',
                      color: context.colorScheme.surface,
                    ),
                  ),
                ),
              ],
            ),
            if (appliedCustomerId != null &&
                appliedCustomerId == selectedCustomerId)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ThemeTypography.bodySmall(
                  context,
                  'Seçili müşteri aktif.',
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
