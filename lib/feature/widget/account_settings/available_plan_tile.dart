part of '../../page/account_settings.dart';

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
        selected ? const Color(0xFF1570EF) : borderColor;
    final effectiveBackgroundColor =
        selected ? const Color(0xFFEAF2FF) : backgroundColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: effectiveBorderColor,
            width: selected ? 2.2 : 1.4,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selected) ...[
              Container(
                margin: const EdgeInsets.only(right: 10, top: 2),
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1570EF),
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontWeight: FontWeight.w700,
                      fontSize: 36 / 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description.isNotEmpty
                        ? plan.description
                        : 'Abonelik planı',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.divider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${plan.quota ?? 0} FATURA   •   ${_periodLabel(plan.period).toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF1570EF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.priceLabel,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontWeight: FontWeight.w700,
                    fontSize: 44 / 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _periodLabel(plan.period),
                  style: const TextStyle(color: Color(0xFF98A2B3)),
                ),
              ],
            ),
          ],
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
