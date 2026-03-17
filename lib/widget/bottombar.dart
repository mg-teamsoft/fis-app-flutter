import 'package:flutter/material.dart';
import 'package:fis_app_flutter/theme/theme.dart';

class WidgetBottomBar extends StatelessWidget {
  const WidgetBottomBar(
      {super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final Function(int) onTap;
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        height: ThemeSize.bottomBarHeight,
        shape: const CircularNotchedRectangle(),
        notchMargin: ThemeSize.spacingS,
        color: context.appTheme.brandPrimary
            .withValues(alpha: 0.1, blue: 0.05, red: 0.05, green: 0.05),
        elevation: ThemeSize.spacingS,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context,
                icon: Icons.home_rounded, index: '/home', label: "AnaSayfa"),
            _buildNavItem(context,
                icon: Icons.receipt_rounded,
                index: '/gallery',
                label: "Fişler"),
            SizedBox(width: ThemeSize.iconXL),
            _buildNavItem(context,
                icon: Icons.group_rounded, index: '/connections', label: "Kişiler"),
            _buildNavItem(context,
                icon: Icons.settings, index: '/settings', label: "Ayarlar"),
          ],
        ));
  }

  Widget _buildNavItem(BuildContext context,
      {required IconData icon, required String index, required String label}) {
    final isSelected = ModalRoute.of(context)?.settings.name == index;
    final color = isSelected
        ? context.colorScheme.secondary
        : context.appTheme.divider.withValues(alpha: 0.7);
    return InkWell(
      onTap: () {
        if (!isSelected) {
          Navigator.of(context).pushNamed(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: ThemeSize.iconLarge,
            color: color,
            semanticLabel: label,
          ),
          ThemeTypography.bodySmall(context, label, color: color)
        ],
      ),
    );
  }
}
