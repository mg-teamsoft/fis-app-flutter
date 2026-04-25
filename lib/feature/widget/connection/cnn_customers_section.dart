part of '../../page/connection_page.dart';

class _CnnCustomersSection extends StatelessWidget {
  const _CnnCustomersSection({
    required this.isCustomersLoading,
    required this.customers,
    required this.customersError,
    required this.onRetry,
  });

  final bool isCustomersLoading;
  final List<_Customer> customers;
  final String? customersError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isCustomersLoading) {
      return const Padding(
        padding: ThemePadding.verticalSymmetricLarge(),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (customersError != null) {
      return Container(
        padding: const ThemePadding.all16(),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: ThemeRadius.circular12,
          border: Border.all(color: context.theme.error),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeTypography.bodyMedium(
              context,
              customersError!,
              color: context.theme.error,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            ElevatedButton(
              onPressed: onRetry,
              child: ThemeTypography.bodyMedium(
                context,
                'Tekrar Dene',
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (customers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const ThemePadding.all16(),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: ThemeRadius.circular12,
          border: Border.all(color: context.theme.divider),
        ),
        child: ThemeTypography.bodyMedium(
          context,
          'Henüz bir müşteri bağlantısı bulunmuyor.',
          color: context.colorScheme.onSurface,
        ),
      );
    }

    return Column(
      children: customers
          .map(
            (customer) => _CnnCustomerCard(customer: customer),
          )
          .toList(),
    );
  }
}

class _CnnCustomerCard extends StatelessWidget {
  const _CnnCustomerCard({required this.customer});

  final _Customer customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const ThemePadding.marginBottom12(),
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.theme.divider, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: ThemeSize.iconMedium,
                backgroundColor: customer.baseColor.withValues(alpha: 0.1),
                child: ThemeTypography.bodyLarge(
                  context,
                  customer.initials,
                  color: customer.baseColor,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: ThemeSize.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemeTypography.bodyLarge(
                      context,
                      customer.name,
                      color: context.colorScheme.onSurface,
                      weight: FontWeight.w800,
                    ),
                    ThemeTypography.bodyMedium(
                      context,
                      customer.email,
                      color: context.colorScheme.onSurface,
                      weight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSize.spacingM),
          const Divider(height: 1),
          const SizedBox(height: ThemeSize.spacingM),
          Row(
            children: [
              if (customer.canViewReceipts)
                const _CnnPermissionChip(
                  icon: Icons.receipt_long_rounded,
                  label: 'Fişleri Görüntüle',
                ),
              if (customer.canViewReceipts && customer.canDownloadFiles)
                const SizedBox(width: ThemeSize.spacingS),
              if (customer.canDownloadFiles)
                const _CnnPermissionChip(
                  icon: Icons.download_rounded,
                  label: 'Dosya İndir',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
