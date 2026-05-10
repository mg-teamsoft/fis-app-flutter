part of '../../page/account_settings_page.dart';

class _AccountSettingsEmptyPlanCard extends StatelessWidget {
  const _AccountSettingsEmptyPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.theme.divider),
      ),
      child: ThemeTypography.bodyLarge(
        context,
        'Plan bulunamadı.',
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    this.details,
  });

  final String message;
  final String? details;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const ThemePadding.all32(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_rounded,
              size: ThemeSize.iconLarge,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            ThemeTypography.titleMedium(
              context,
              message,
              color: context.colorScheme.onSurface,
              weight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: ThemeSize.spacingXs),
              ThemeTypography.bodySmall(
                context,
                details!,
                color: context.colorScheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: ThemeSize.spacingM),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
                size: ThemeSize.iconMedium,
              ),
              label: ThemeTypography.bodyMedium(
                context,
                'Tekrar Dene',
                color: context.colorScheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductLoadFallbackCard extends StatelessWidget {
  const _ProductLoadFallbackCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withValues(alpha: 0.25),
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.colorScheme.errorContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.storefront_outlined,
                color: context.colorScheme.error,
                size: ThemeSize.iconMedium,
              ),
              const SizedBox(width: ThemeSize.spacingS),
              Expanded(
                child: ThemeTypography.bodyMedium(
                  context,
                  message,
                  color: context.colorScheme.onSurface,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSize.spacingS),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: ThemeTypography.bodyMedium(
              context,
              'Tekrar dene',
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
