import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/widget/cardinvoice.dart';
import 'package:fis_app_flutter/model/home_summary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WidgetCardArea extends StatelessWidget {
  const WidgetCardArea({
    required this.summary,
    super.key,
  });

  final HomeSummary summary;
  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormatter = DateFormat('d MMMM', 'tr_TR');

    final receipts = summary.recentReceipts;
    if (receipts.isEmpty) {
      return Center(
        child: Padding(
          padding: const ThemePadding.all20(),
          child: ThemeTypography.h4(context, 'Fiş Bulunamadı'),
        ),
      );
    }
    return ListView.builder(
      itemCount: receipts.length >= 3 ? 3 : receipts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const ThemePadding.all10(),
      itemBuilder: (context, index) {
        final item = receipts[index];
        final date = item.transactionDate;
        final dateText =
            date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
        final amountText = currencyFormatter.format(item.totalAmount);

        return Padding(
          padding: const ThemePadding.all10(),
          child: WidgetCardInvoice(
            summary: item,
            id: item.receiptNumber,
            name: item.businessName,
            amoung: amountText,
            date: dateText,
            badge: item.status,
          ),
        );
      },
    );
  }
}
