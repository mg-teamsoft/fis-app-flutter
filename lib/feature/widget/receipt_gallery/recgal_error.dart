part of '../../page/receipt_gallery_page.dart';

final class _GalleryError extends StatelessWidget {
  const _GalleryError({
    required this.message,
    required this.onRetry,
    this.details,
  });

  final String message;
  final String? details;
  final VoidCallback onRetry;

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
              message,
              textAlign: TextAlign.center,
              color: context.colorScheme.error,
            ),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: ThemeSize.spacingS),
              ThemeTypography.bodySmall(
                context,
                details!,
                color: context.theme.warning,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: ThemeSize.spacingM),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
              ),
              icon: Icon(
                Icons.refresh,
                size: ThemeSize.iconXL,
                color: context.colorScheme.onPrimary,
              ),
              label: ThemeTypography.bodyLarge(
                context,
                'Tekrar dene',
                color: context.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
