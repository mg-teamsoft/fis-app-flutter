import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class WidgetBottomBar extends StatelessWidget {
  const WidgetBottomBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  static const double _navIconSize = 24;
  static const double _navItemSpacing = 2;

  final int currentIndex;
  final void Function(int) onTap;
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        height: ThemeSize.bottomBarHeight,
        shape: const CircularNotchedRectangle(),
        notchMargin: ThemeSize.spacingS,
        color: context.colorScheme.surface,
        elevation: ThemeSize.spacingS,
        shadowColor: context.colorScheme.onSurface,
        surfaceTintColor: context.colorScheme.onSurface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home_rounded,
              index: '/home',
              label: 'AnaSayfa',
            ),
            _buildNavItem(
              context,
              icon: Icons.receipt_rounded,
              index: '/gallery',
              label: 'Fişler',
            ),
            const SizedBox(width: ThemeSize.iconXL),
            _buildNavItem(
              context,
              icon: Icons.group_rounded,
              index: '/connections',
              label: 'Kişiler',
            ),
            _buildNavItem(
              context,
              icon: Icons.settings,
              index: '/settings',
              label: 'Ayarlar',
            ),
          ],
        ));
  }

  Widget _buildNavItem(BuildContext context,
      {required IconData icon, required String index, required String label}) {
    final isSelected = ModalRoute.of(context)?.settings.name == index;
    final color = isSelected
        ? context.colorScheme.primary
        : context.colorScheme.onSurface.withValues(alpha: 0.9);
    return InkWell(
      onTap: () async {
        if (!isSelected) {
          await Navigator.of(context).pushNamed(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _navIconSize,
            color: color,
            semanticLabel: label,
          ),
          const SizedBox(height: _navItemSpacing),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
