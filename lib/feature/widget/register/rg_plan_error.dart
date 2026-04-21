part of '../../page/register_page.dart';

final class _PlanErrorState extends StatelessWidget {
  const _PlanErrorState({
    required this.message,
    required this.onRetry,
    this.details,
  });

  final String message;
  final String? details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: ThemeRadius.circular16,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: ThemeSize.iconMedium,
              ),
              const SizedBox(width: ThemeSize.spacingS),
              Expanded(
                child: ThemeTypography.bodyMedium(
                  context,
                  message,
                  weight: FontWeight.w600,
                  color: context.theme.error,
                ),
              ),
            ],
          ),
          if (details != null && details!.isNotEmpty) ...[
            const SizedBox(height: ThemeSize.spacingS),
            ThemeTypography.bodySmall(
              context,
              details!,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
          const SizedBox(height: ThemeSize.spacingS),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: ThemeTypography.bodyMedium(
                context,
                'Tekrar dene',
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
