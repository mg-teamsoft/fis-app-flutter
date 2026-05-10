part of '../../page/receipt_detail_page.dart';

final class _ReceiptDetailError extends StatelessWidget {
  const _ReceiptDetailError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const ThemePadding.all24(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: ThemeSize.avatarLarge,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: ThemeSize.spacingM),
            ThemeTypography.titleMedium(
              context,
              message,
              color: context.theme.error,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: ThemeSize.spacingM),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: ThemeTypography.bodyMedium(
                  context,
                  'Tekrar dene',
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
