import 'package:fis_app_flutter/models/home_summary.dart';
import 'package:fis_app_flutter/widget/perchart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/theme.dart';

class FeatureHomeHeader extends StatelessWidget {
  const FeatureHomeHeader({super.key, required this.summary});

  final HomeSummary summary;
  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final totalSpentText = currencyFormatter.format(summary.totalSpent);
    final monthlyLimit = currencyFormatter.format(summary.monthlyLimitAmount);
    final hasMonthlyLimit = summary.monthlyLimitAmount > 0;
    final usageFraction = hasMonthlyLimit && summary.monthlyLimitAmount > 0
        ? (summary.totalSpent / summary.monthlyLimitAmount).clamp(0.0, 1.2)
        : 0.0;
    final percentageText = hasMonthlyLimit
        ? '${(usageFraction * 100).clamp(0, 120).round()}%'
        : '—';
    return Column(
      children: [
        ThemeTypography.h4(context, "Toplam Bakiye",
            color: context.colorScheme.onPrimary.withValues(alpha: 0.35)),
        SizedBox(height: ThemeSize.spacingS),
        ThemeTypography.h2(context, totalSpentText),
        SizedBox(height: ThemeSize.spacingS),
        WidgetPerChart(
          value: 0.9,
          label: hasMonthlyLimit ? percentageText : 'Limit tanımlı değil',
        ),
        SizedBox(height: ThemeSize.spacingS),
      
        ThemeTypography.titleLarge(
            context, hasMonthlyLimit ? monthlyLimit : 'Limit yok',
            color: context.colorScheme.onPrimary),
        SizedBox(
          height: ThemeSize.spacingL,
        )
      ],
    );
  }
}
