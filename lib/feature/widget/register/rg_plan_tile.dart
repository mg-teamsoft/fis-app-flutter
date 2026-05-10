part of '../../page/register_page.dart';

final class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PlanOption plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? context.colorScheme.primary
        : context.colorScheme.outlineVariant;
    final backgroundColor = selected
        ? context.colorScheme.primary.withValues(alpha: 0.08)
        : context.colorScheme.surface;
    final priceText = plan.billingCycle.isNotEmpty
        ? '${plan.priceLabel}/${plan.billingCycle}'
        : plan.priceLabel;
    final badgeText = (plan.badge != null && plan.badge!.trim().isNotEmpty)
        ? plan.badge!.trim()
        : (plan.isPopular ? 'Popüler' : null);
    final badgeBackground = selected
        ? context.colorScheme.primary
        : context.colorScheme.secondaryContainer;
    final badgeForeground = selected
        ? context.colorScheme.onPrimary
        : context.colorScheme.onSecondaryContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const ThemePadding.all16(),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          borderRadius: ThemeRadius.circular16,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ThemeTypography.titleMedium(
                        context,
                        plan.name,
                        weight: FontWeight.w600,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    ThemeTypography.titleMedium(
                      context,
                      priceText,
                      weight: FontWeight.w700,
                      color: context.colorScheme.onSurface,
                    ),
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: context.colorScheme.primary,
                          child: Icon(
                            Icons.check,
                            color: context.colorScheme.onPrimary,
                            size: ThemeSize.iconSmall,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: ThemeSize.spacingS),
                ThemeTypography.bodyMedium(
                  context,
                  plan.description.isNotEmpty
                      ? plan.description
                      : 'Plan detayları yakında.',
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            if (badgeText != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ThemeTypography.labelSmall(
                    context,
                    badgeText,
                    color: badgeForeground,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
