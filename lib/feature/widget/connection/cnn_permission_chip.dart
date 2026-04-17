part of '../../page/connection_page.dart';

class _CnnPermissionChip extends StatelessWidget {
  const _CnnPermissionChip({required this.label, required this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular8,
        border: Border.all(color: context.theme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: ThemeSize.iconSmall,
                color: context.colorScheme.onSurface),
            const SizedBox(width: ThemeSize.spacingXs),
          ],
          ThemeTypography.bodySmall(
            context,
            label,
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
