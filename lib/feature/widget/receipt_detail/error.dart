part of '../../page/receipt_detail.dart';

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
            const SizedBox(height: 16),
            Text(
              message,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: ThemeSize.spacingM),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
