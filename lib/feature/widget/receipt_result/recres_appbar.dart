part of '../../page/receipt_result_page.dart';

class _ReceiptResultAppbar extends StatefulWidget
    implements PreferredSizeWidget {
  const _ReceiptResultAppbar({
    required this.showOnlySelected,
  });

  final bool showOnlySelected;

  @override
  State<_ReceiptResultAppbar> createState() => __ReceiptResultAppbarState();

  @override
  Size get preferredSize => const Size(double.infinity, ThemeSize.appBarHeight);
}

class __ReceiptResultAppbarState extends State<_ReceiptResultAppbar> {
  late bool showOnlySelected;

  @override
  void initState() {
    super.initState();
    showOnlySelected = widget.showOnlySelected;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Sonuçlar',
        style: context.textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          tooltip: showOnlySelected
              ? 'Tüm fişleri göster'
              : 'Sadece seçilenleri göster',
          icon: Icon(
            Icons.filter_list,
            color: showOnlySelected ? context.colorScheme.primary : null,
          ),
          onPressed: () {
            setState(() {
              showOnlySelected = !showOnlySelected;
            });
          },
        ),
      ],
    );
  }
}
