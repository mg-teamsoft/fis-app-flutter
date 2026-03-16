part of '../../../page/receipt_gallery.dart';

class _ReceiptGallerySearchBar extends StatelessWidget {
  const _ReceiptGallerySearchBar({
    super.key,
    required this.onChanged, required this.onSuffixTap});

  final ValueChanged<String> onChanged;
  final VoidCallback onSuffixTap;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Arama',
      leading: IconButton(onPressed: onSuffixTap, icon: Icon(Icons.search,
          color: context.colorScheme.secondary, size: ThemeSize.iconLarge)),
      onChanged: onChanged,
      padding: WidgetStatePropertyAll(ThemePadding.all10()),
      elevation: WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(context.colorScheme.primary),
      side: WidgetStatePropertyAll(
          BorderSide(color: context.colorScheme.outline)),
    );
  }
}
