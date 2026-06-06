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
    required this.isNotifying,
    required this.isManagerNotified,
    required this.notifyUpdate,
    required this.hasManager,
    required this.notifyManager,
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
  final bool isNotifying;
  final bool isManagerNotified;
  final Future<void> Function() notifyUpdate;
  final bool hasManager;
  final Future<void> Function() notifyManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: hasManager
          ? FloatingActionButton.extended(
              onPressed:
                  isNotifying || isManagerNotified ? null : notifyManager,
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              icon: isNotifying
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      isManagerNotified
                          ? Icons.check
                          : Icons.notifications_active,
                    ),
              label: Text(
                isManagerNotified
                    ? 'Bilgilendirme Gönderildi'
                    : 'Yöneticiyi Bilgilendir',
              ),
            )
          : null,
      body: Padding(
        padding: const ThemePadding.all16(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ThemeTypography.h4(
                context,
                'Excel Dosyaları',
                weight: FontWeight.w900,
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
            if (appliedCustomerId != null) ...[
              const SizedBox(height: ThemeSize.spacingM),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: isNotifying ? null : notifyUpdate,
                  icon: isNotifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.notifications_active),
                  label: const Text('Kullanıcıya Bildir'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: ThemeSize.spacingM),
            _ExcelBuilder(
              future: future,
              busy: busy,
              open: open,
              download: download,
            ),
          ],
        ),
      ),
    );
  }
}
