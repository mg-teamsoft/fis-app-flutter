import 'package:fis_app_flutter/models/home_summary.dart';

import 'package:fis_app_flutter/models/receipt_summary.dart';
import 'package:fis_app_flutter/widget/cardinvoice.dart';
import 'package:flutter/material.dart';
import 'package:fis_app_flutter/theme/theme.dart';
import 'package:intl/intl.dart';

class WidgetCardArea extends StatelessWidget {
  const WidgetCardArea({super.key, required this.summary});

  final HomeSummary summary;
  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final dateFormatter = DateFormat('d MMMM', 'tr_TR');

    final List<ReceiptSummary> receipts = summary.recentReceipts;
    if (receipts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ThemeTypography.h4(context, 'Fiş Bulunamadı'),
        ),
      );
    }
    return ListView.builder(
        itemCount: receipts.length >= 3 ? 3 : receipts.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: ThemePadding.all10(),
        itemBuilder: (context, index) {
          final item = receipts[index];
          final date = item.transactionDate;
          final dateText =
              date != null ? dateFormatter.format(date) : 'Tarih bilgisi yok';
          final amountText = currencyFormatter.format(item.totalAmount);

          return Padding(
            padding: EdgeInsets.only(bottom: ThemeSize.spacingS),
            child: WidgetCardInvoice(
              summary: item,
              id: item.receiptNumber,
              name: item.businessName,
              amoung: amountText,
              date: dateText,
              badge: item.status,
            ),
          );
        });
  }
}
