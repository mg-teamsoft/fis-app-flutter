part of '../../../page/receipt_gallery.dart';

class _ReceiptGalleryHeader extends StatelessWidget {
  const _ReceiptGalleryHeader({required this.onSearchChanged, required this.onFilter});

  final void Function(String) onSearchChanged;
  final void Function(String sortName) onFilter;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [_TopHeader(onFilter: onFilter,), _BottomHeader(onSearchChanged: onSearchChanged)],
    );
  }
}

final class _MenuContent extends StatelessWidget {
  const _MenuContent({required this.label, required this.icon});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: ThemeSize.spacingS,
      children: [
        Icon(icon,
            size: ThemeSize.iconLarge, color: context.colorScheme.onSurface),
        ThemeTypography.bodyLarge(context, label,
            color: context.colorScheme.onSurface)
      ],
    );
  }
}

final class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.onFilter
  });

  final void Function(String sortName) onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: ThemeSize.spacingM,
      children: [
        ThemeTypography.h2(context, 'Fişler'),
        PopupMenuButton<String>(
          icon: Icon(Icons.filter_alt_rounded,
              size: ThemeSize.iconLarge, color: context.colorScheme.secondary),
          position: PopupMenuPosition.under,
          color: context.colorScheme.secondaryContainer,
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                  onTap: () => onFilter('sort_a_z'),
                  child: _MenuContent(
                      label: 'A’dan Z’ye Sırala',
                      icon: Icons.vertical_align_bottom_rounded)),
              PopupMenuItem(
                onTap: () => onFilter('sort_z_a'),
                  child: _MenuContent(
                      label: 'Z’dan A’ye Sırala',
                      icon: Icons.vertical_align_top_rounded)),
              PopupMenuItem(
                onTap: () => onFilter('sort_last_add'),
                  child: _MenuContent(
                      label: 'Son Eklenenler',
                      icon: Icons.arrow_drop_up_rounded)),
              PopupMenuItem(
                onTap: () => onFilter('sort_firt_add'),
                  child: _MenuContent(
                      label: 'İlk Eklenenler',
                      icon: Icons.arrow_drop_down_rounded)),
              PopupMenuItem(
                onTap: () => onFilter('sort_high_price'),
                  child: _MenuContent(
                      label: 'En Yüksek Tutar',
                      icon: Icons.attach_money_rounded)),
              PopupMenuItem(
                onTap: () => onFilter('sort_low_price'),
                  child: _MenuContent(
                      label: 'En Düşük Tutar',
                      icon: Icons.money_off_rounded)),
            ];
          },
        )
      ],
    );
  }
}

class _BottomHeader extends StatefulWidget {
  const _BottomHeader({required this.onSearchChanged});
  final void Function(String) onSearchChanged;

  @override
  State<_BottomHeader> createState() => __BottomHeaderState();
}

class __BottomHeaderState extends State<_BottomHeader> {
  bool _isSearch = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
        alignment:
            Alignment.centerRight,
        height: ThemeSize.appBarHeight,
      child:AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation.drive(Tween(begin: 0.95, end: 1.0)),
              child: child,
            ),
          );
        },
        child: _isSearch
            ? _ReceiptGallerySearchBar(
              key: const ValueKey('searchBar'),
              onSuffixTap: () => setState(() {
                 _isSearch = !_isSearch;
              }),
              onChanged: widget.onSearchChanged)
            : IconButton(
                key: const ValueKey('searchButton'),
                onPressed: () => setState(() {
                      _isSearch = !_isSearch;
                    }),
                icon: Icon(Icons.search,
                    size: ThemeSize.iconLarge,
                    color: context.colorScheme.secondary))));
  }
}
