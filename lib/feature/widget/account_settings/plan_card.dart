part of '../../page/account_settings.dart';

class _ActiveSettingsPlanCard extends StatelessWidget {
  const _ActiveSettingsPlanCard({
    required this.plan,
    required this.onBuyAdditional,
  });

  final PlanOption plan;
  final VoidCallback? onBuyAdditional;

  @override
  Widget build(BuildContext context) {
    final price = plan.priceLabel;
    final renewLabel = _renewLabel(plan.period);

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
                          horizontal: 10, vertical: 4),
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
                      plan.name,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.w700,
                        fontSize: 36 / 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${plan.quota ?? 0} fatura/ay  •  $renewLabel',
                      style: const TextStyle(
                          color: Color(0xFF667085), fontSize: 28 / 2),
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
              onPressed: onBuyAdditional,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1570EF),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text(
                'Ek 100 Satın Al',
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
