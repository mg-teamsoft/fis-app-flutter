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
    final renewLabel = _renewLabel(widget.plan.period);
    final remainingQuota =
        context.watch<UserPlanProvider?>()?.remainingQuota ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1570EF), width: 2),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'MEVCUT PLAN',
                        style: TextStyle(
                          color: Color(0xFF1570EF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.plan.name,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.w700,
                        fontSize: 36 / 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.plan.quota ?? 0} fatura/ay  •  $renewLabel',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.divider,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kalan Kota: $remainingQuota',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF1570EF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontWeight: FontWeight.w800,
                      fontSize: 44 / 2,
                    ),
                  ),
                  const Text(
                    'aylık',
                    style: TextStyle(color: Color(0xFF667085)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  widget.onBuyAdditional!(widget.additionalPlans.first),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1570EF),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text(
                'Ek ${widget.additionalPlans.first.quota} Kota Satın Al ${widget.additionalPlans.first.priceLabel}',
                style: TextStyle(fontSize: 32 / 2, fontWeight: FontWeight.w700),
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
