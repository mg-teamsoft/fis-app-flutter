import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/model/receipt_summary.dart';
import 'package:fis_app_flutter/pages/receipt_detail_page.dart';
import 'package:flutter/material.dart';

class WidgetCardInvoice extends StatelessWidget {
  const WidgetCardInvoice({
    required this.summary,
    required this.id,
    required this.name,
    required this.amoung,
    required this.date,
    required this.badge,
    super.key,
    this.size = const Size(double.infinity, 80),
  });

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
      onTap: () async {
        FocusScope.of(context).unfocus();
        await _openDetails(context, summary);
      },
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: context.theme.cardBackground.withValues(alpha: 0.7),
          borderRadius: ThemeRadius.circular12,
        ),
        padding: const ThemePadding.all10(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: ThemeSize.avatarMedium,
                    height: ThemeSize.avatarMedium,
                    child: Icon(
                      Icons.receipt_long,
                      size: ThemeSize.iconMedium,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                  Expanded(
                    child: ThemeTypography.titleLarge(
                      context,
                      name,
                      color: context.colorScheme.onSurface,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeTypography.titleMedium(
                  context,
                  amoung,
                  color: context.colorScheme.onSurface,
                ),
                ThemeTypography.titleMedium(context, date),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetails(
    BuildContext context,
    ReceiptSummary summary,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ReceiptDetailPage(receiptId: summary.id),
      ),
    );
  }
}
