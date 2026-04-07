part of '../../page/home_page.dart';

final class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.dateString, required this.model});

  final ModelHome model;
  final String dateString;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final totalSpentText = currencyFormatter.format(model.totalSpent);
    final hasMonthlyLimit = model.monthlyLimitAmount > 0;
    final usageFraction = hasMonthlyLimit && model.monthlyLimitAmount > 0
        ? (model.totalSpent / model.monthlyLimitAmount).clamp(0.0, 1.2)
        : 0.0;
    final percentageText = hasMonthlyLimit
        ? '${(usageFraction * 100).clamp(0, 120).round()}%'
        : '—';

    return Column(
      children: [
        const SizedBox(height: 18),
        Text(
          'Aylık Birikim',
          style: context.textTheme.headlineSmall,
        ),
        Text(
          dateString,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          totalSpentText,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: ThemeSize.spacingM),
        _TargetProgressRing(
          progress: usageFraction,
          percentageText: percentageText,
          hasLimit: hasMonthlyLimit,
          limitText: hasMonthlyLimit
              ? currencyFormatter.format(model.monthlyLimitAmount)
              : 'Limit tanımlı değil',
        ),
      ],
    );
  }
}
