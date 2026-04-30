part of '../../page/home_page.dart';

final class _InvoiceItem extends StatelessWidget {
  const _InvoiceItem({
    required this.title,
    required this.date,
    required this.amount,
  });

  final String title;
  final String date;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.receipt_long, color: context.colorScheme.primary),
      title: ThemeTypography.bodyMedium(
        context,
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        weight: FontWeight.w600,
        color: context.colorScheme.onSurfaceVariant,
      ),
      subtitle: ThemeTypography.bodySmall(
        context,
        date,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        color: context.colorScheme.onSurfaceVariant,
      ),
      trailing: ThemeTypography.bodyMedium(
        context,
        amount,
        weight: FontWeight.w500,
        color: context.colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: ThemeRadius.circular12,
      ),
      tileColor: context.colorScheme.surface,
    );
  }
}
