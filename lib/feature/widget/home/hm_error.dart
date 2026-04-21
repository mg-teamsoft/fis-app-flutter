part of '../../page/home_page.dart';

final class _HomeError extends StatelessWidget {
  const _HomeError({
    required this.onRetry,
    this.details,
  });

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
              Icons.error_outline,
              size: ThemeSize.iconXL,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            ThemeTypography.titleMedium(
              context,
              'Veriler alınırken bir hata oluştu.',
              textAlign: TextAlign.center,
              color: context.colorScheme.onSurfaceVariant,
            ),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: ThemeSize.spacingS),
              ThemeTypography.bodySmall(
                context,
                details!,
                textAlign: TextAlign.center,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
            const SizedBox(height: ThemeSize.spacingM),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: ThemeSize.iconMedium),
              label: ThemeTypography.bodyMedium(
                context,
                'Tekrar dene',
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
