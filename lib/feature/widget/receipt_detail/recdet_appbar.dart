part of '../../page/receipt_detail_page.dart';

class _ReceiptDetailAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ReceiptDetailAppbar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: ThemeTypography.titleLarge(
        context,
        'Fiş Detayı',
        color: context.colorScheme.onSurface,
      ),
      scrolledUnderElevation: 0.3,
      elevation: 0.3,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: context.colorScheme.onSurface,
          height: 1,
        ),
      ),
      backgroundColor: context.colorScheme.surface.withValues(alpha: 0.2),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          color: context.colorScheme.onSurface,
          iconSize: ThemeSize.iconMedium,
          onPressed: () {},
          tooltip: 'Düzenle',
        ),
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: context.colorScheme.onSurface,
            size: ThemeSize.iconMedium,
          ),
          onPressed: () {},
          tooltip: 'Paylaş',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, ThemeSize.appBarHeight);
}
