import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/model/receipt_summary.dart';
import 'package:fis_app_flutter/pages/receipt_detail_page.dart';
import 'package:flutter/material.dart';

class WidgetCardInvoice extends StatelessWidget {
  const WidgetCardInvoice(
      {super.key,
      required this.summary,
      required this.id,
      required this.name,
      required this.amoung,
      required this.date,
      required this.badge,
      this.size = const Size(double.infinity, 80)});

  final String id;
  final ReceiptSummary summary;
  final String date;
  final String amoung;
  final String? badge;
  final String name;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          _openDetails(context, summary);
        },
        child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: context.theme.cardBackground.withValues(alpha: 0.7),
              borderRadius: ThemeRadius.circular12,
            ),
            padding: ThemePadding.all10(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      SizedBox(
                        width: ThemeSize.avatarMedium,
                        height: ThemeSize.avatarMedium,
                        child: Icon(Icons.receipt_long,
                            size: ThemeSize.iconMedium,
                            color: context.colorScheme.onPrimary),
                      ),
                      Expanded(
                        flex: 1,
                        child: ThemeTypography.titleLarge(
                          context,
                          name,
                          color: context.colorScheme.onSurface,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ThemeTypography.titleMedium(context, amoung,
                        color: context.colorScheme.onSurface),
                    ThemeTypography.titleMedium(context, date),
                  ],
                )
              ],
            )));
  }

  void _openDetails(BuildContext context, ReceiptSummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailPage(receiptId: summary.id),
      ),
    );
  }
}
