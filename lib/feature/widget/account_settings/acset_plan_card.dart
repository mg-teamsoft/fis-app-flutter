part of '../../page/account_settings_page.dart';

class _ActiveSettingsPlanCard extends StatefulWidget {
  const _ActiveSettingsPlanCard({
    required this.plan,
    required this.additionalPlans,
    required this.onBuyAdditional,
  });

  final PlanOption plan;
  final List<PlanOption> additionalPlans;
  final Future<void> Function(PlanOption plan)? onBuyAdditional;

  @override
  State<_ActiveSettingsPlanCard> createState() =>
      _ActiveSettingsPlanCardState();
}

class _ActiveSettingsPlanCardState extends State<_ActiveSettingsPlanCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<UserPlanProvider?>()?.loadMyPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.plan.priceLabel;

    // ignore: unused_local_variable
    final renewLabel = _renewLabel(widget.plan.period);
    final remainingQuota =
        context.watch<UserPlanProvider?>()?.remainingQuota ?? 0;

    return Container(
      padding: const ThemePadding.all20(),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular12,
        border: Border.all(color: context.colorScheme.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const ThemePadding.all10(),
                      decoration: BoxDecoration(
                        color: context.colorScheme.outline.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: ThemeTypography.bodySmall(
                        context,
                        'MEVCUT PLAN',
                        color: context.colorScheme.primary,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: ThemeSize.spacingXs),
                    ThemeTypography.bodyLarge(
                      context,
                      widget.plan.name,
                      color: context.colorScheme.onSurface,
                      weight: FontWeight.w700,
                    ),
                    const SizedBox(height: ThemeSize.spacingXs),
                    ThemeTypography.bodyMedium(
                      context,
                      widget.plan.description,
                      color: context.theme.divider,
                    ),
                    const SizedBox(height: ThemeSize.spacingXs),
                    ThemeTypography.bodyMedium(
                      context,
                      'Kalan Kota: $remainingQuota',
                      color: context.colorScheme.primary,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ThemeSize.spacingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ThemeTypography.h4(
                    context,
                    price,
                    color: context.colorScheme.onSurface,
                    weight: FontWeight.w800,
                  ),
                  ThemeTypography.bodyMedium(
                    context,
                    'aylık',
                    color: context.theme.divider,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: ThemeSize.spacingM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  widget.onBuyAdditional!(widget.additionalPlans.first),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(ThemeSize.buttonHeightLarge),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    size: ThemeSize.iconMedium,
                    color: context.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: ThemeSize.spacingS),
                  Expanded(
                    child: ThemeTypography.labelSmall(
                      context,
                      'Ek ${widget.additionalPlans.first.quota} Kota Al - ${widget.additionalPlans.first.priceLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      color: context.colorScheme.onPrimary,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _renewLabel(String period) {
    final value = period.toLowerCase();
    if (value.contains('month')) return 'Aylık yenilenir';
    if (value.contains('year') || value.contains('annual')) {
      return 'Yıllık yenilenir';
    }
    return 'Otomatik yenilenir';
  }
}
