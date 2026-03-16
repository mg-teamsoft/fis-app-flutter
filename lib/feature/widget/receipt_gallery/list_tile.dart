part of '../../../page/receipt_gallery.dart';

class _ReceiptGalleryListTile extends StatelessWidget {
  const _ReceiptGalleryListTile({required this.summary,required this.dateText,required this.amountText,required this.onOpenDetails});

 
  final ReceiptSummary summary;
  final String dateText;
  final String amountText;
  final void Function(ReceiptSummary) onOpenDetails;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      onTap: () => onOpenDetails(summary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tileColor: context.colorScheme.surface,
      leading: Icon(Icons.receipt_long, color: context.colorScheme.onPrimary),
      title: ThemeTypography.titleLarge(context, summary.businessName,overflow: TextOverflow.ellipsis,),


      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end, 
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: ThemeSize.spacingS,
        children: [
          ThemeTypography.titleSmall(context, amountText),
          ThemeTypography.titleSmall(context, dateText)
        ],
      )

    );
  }
}