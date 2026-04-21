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
        ThemeTypography.h4(
          context,
          'Aylık Birikim',
          weight: FontWeight.w900,
          color: context.colorScheme.onSurface,
        ),
        ThemeTypography.bodyMedium(
          context,
          dateString,
          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(height: ThemeSize.spacingXs),
        ThemeTypography.h2(
          context,
          totalSpentText,
          weight: FontWeight.w900,
          textAlign: TextAlign.center,
          color: context.colorScheme.onSurface,
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
