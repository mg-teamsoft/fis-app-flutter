class PlanOption {
  PlanOption({
    required this.id,
    required this.planKey,
    required this.name,
    required this.description,
    required this.priceLabel,
    required this.billingCycle,
    required this.priceAmount,
    required this.period,
    required this.quota,
    required this.isPopular,
    required this.badge,
  });

  final String id;
  final String planKey;
  final String name;
  final String description;
  final String priceLabel;
  final String billingCycle;
  final double? priceAmount;
  final String period;
  final int? quota;
  final bool isPopular;
  final String? badge;
  bool get isFreePlan =>
      planKey.toLowerCase().contains('free') ||
      priceAmount == null ||
      priceAmount! <= 0.0;

  factory PlanOption.fromJson(Map<String, dynamic> json) {
    String readString(String key) => json[key]?.toString().trim() ?? '';

    double? readDouble(String key) {
      final value = json[key];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    String currencySymbolFor(String currency) {
      switch (currency.toUpperCase()) {
        case 'USD':
          return '\$';
        case 'EUR':
          return '€';
        case 'GBP':
          return '£';
        case 'TRY':
        case 'TL':
          return '₺';
        default:
          return currency;
      }
    }

    String normalizePeriod(String period) {
      switch (period.toLowerCase()) {
        case 'monthly':
        case 'month':
        case 'mo':
          return 'mo';
        case 'yearly':
        case 'annual':
        case 'annually':
        case 'yr':
        case 'year':
          return 'yr';
        case 'weekly':
        case 'week':
          return 'wk';
        case 'daily':
        case 'day':
          return 'day';
        case 'once':
        case 'one_time':
        case 'single':
          return '';
        default:
          return period;
      }
    }

    final priceValue = readDouble('price');
    final currency = readString('currency');
    final currencySymbol =
        currency.isNotEmpty ? currencySymbolFor(currency) : '₺';
    final formattedPrice = priceValue != null
        ? '$currencySymbol${priceValue.toStringAsFixed(priceValue ==
                priceValue.roundToDouble()
            ? 0
            : 2)}'
        : '—';

    final rawPeriod = readString('period');
    final billingCycle = normalizePeriod(rawPeriod);

    final id = readString('id').isNotEmpty ? readString('id') : readString('_id');
    final key = readString('planKey').isNotEmpty
        ? readString('planKey')
        : (readString('key').isNotEmpty ? readString('key') : id);

    final explanation = readString('explanation');
    final description = explanation.isNotEmpty
        ? explanation
        : readString('description');

    final badge = json['badge']?.toString();

    return PlanOption(
      id: id,
      planKey: key,
      name: readString('name'),
      description: description,
      priceLabel: formattedPrice,
      billingCycle: billingCycle,
      priceAmount: priceValue,
      period: rawPeriod,
      quota: int.tryParse(readString('quota')),
      isPopular: json['isPopular'] == true ||
          readString('tag').toLowerCase() == 'popular',
      badge: (badge != null && badge.trim().isNotEmpty) ? badge.trim() : null,
    );
  }
}
