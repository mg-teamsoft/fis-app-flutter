part of '../../page/account_settings_page.dart';

class _AccountSettingsAvailablePlanTile extends StatelessWidget {
  const _AccountSettingsAvailablePlanTile({
    required this.plan,
    required this.selected,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final PlanOption plan;
  final bool selected;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        selected ? context.colorScheme.primary : borderColor;

    return AnimatedScale(
      scale: selected ? 1.025 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const ThemePadding.all10(),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: ThemeRadius.circular16,
            border: Border.all(
              color: effectiveBorderColor,
              width: selected ? 2.5 : 1.4,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color:
                          context.colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selected) ...[
                Container(
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorScheme.primary,
                  ),
                  child: Icon(
                    Icons.check,
                    size: ThemeSize.iconSmall,
                    color: context.colorScheme.surface,
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemeTypography.bodyLarge(
                      context,
                      plan.name,
                      color: context.colorScheme.onSecondary,
                      weight: FontWeight.w700,
                    ),
                    const SizedBox(height: 4),
                    ThemeTypography.bodyMedium(
                      context,
                      plan.description.isNotEmpty
                          ? plan.description
                          : 'Abonelik planı',
                      color: context.colorScheme.onSecondary,
                    ),
                    const SizedBox(height: ThemeSize.spacingM),
                    ThemeTypography.bodyMedium(
                      context,
                      '${plan.quota ?? 0} FATURA   •   ${_periodLabel(plan.period).toUpperCase()}',
                      color: context.colorScheme.primaryContainer,
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ThemeTypography.bodyLarge(
                    context,
                    plan.priceLabel,
                    color: context.colorScheme.onSurface,
                    weight: FontWeight.w700,
                  ),
                  const SizedBox(height: 6),
                  ThemeTypography.bodyMedium(
                    context,
                    _periodLabel(plan.period),
                    color: context.theme.divider,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _periodLabel(String period) {
    final value = period.toLowerCase();
    if (value.contains('month')) return 'Aylık';
    if (value.contains('year') || value.contains('annual')) return 'Yıllık';
    if (value.contains('week')) return 'Haftalık';
    return 'Plan';
  }
}
