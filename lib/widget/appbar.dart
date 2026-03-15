import 'package:fis_app_flutter/widget/popmenu.dart';
import 'package:fis_app_flutter/widget/popmenuitem.dart';
import 'package:flutter/material.dart';
import 'package:fis_app_flutter/theme/theme.dart';

class WidgetAppbar extends StatelessWidget implements PreferredSizeWidget {
  const WidgetAppbar(
      {super.key, required this.showBackButton, required this.onSelected});

  final bool showBackButton;
  final void Function(String)? onSelected;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.appTheme.brandPrimary
            .withValues(alpha: 0.075, blue: 0.05, red: 0.05, green: 0.05),
      ),
      child: SafeArea(
        child: Padding(
          padding: ThemePadding.horizontalSymmetricMedium(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showBackButton
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_ios_new,
                          color: context.appTheme.brandSecondary),
                      onPressed: () => Navigator.pop(context),
                    )
                  : WidgetPopMenu(
                      onSelected: onSelected,
                      icon: Icons.menu_rounded,
                      menuitems: [
                        WidgetPopMenuItem(
                            value: '/home', text: 'Anasayfa', icon: Icons.home),
                        WidgetPopMenuItem(
                            value: '/gallery',
                            text: 'Fişler',
                            icon: Icons.receipt),
                        WidgetPopMenuItem(
                            value: '/group',
                            text: 'Kişiler',
                            icon: Icons.group),
                        WidgetPopMenuItem(
                            value: '/settings',
                            text: 'Ayarlar',
                            icon: Icons.settings),
                      ],
                    ),
              Image.asset('assets/icon/RBGAppIcon.png',
                  height: ThemeSize.iconLarge, width: ThemeSize.iconLarge),
              Row(children: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark
                        ? Colors.orangeAccent
                        : context.appTheme.brandSecondary,
                    size: ThemeSize.iconMedium,
                  ),
                  onPressed: () {
                    ThemeProvider().toggleTheme();
                  },
                ),
                Icon(
                  Icons.notifications,
                  color: context.appTheme.warning,
                ),
                WidgetPopMenu(
                    onSelected: onSelected,
                    icon: Icons.person_pin,
                    menuitems: [
                      WidgetPopMenuItem(
                          value: '/about',
                          text: 'Hakkında',
                          icon: Icons.question_mark_outlined),
                      WidgetPopMenuItem(
                          value: '/accountSettings',
                          text: 'Hesap Ayarları',
                          icon: Icons.settings),
                      WidgetPopMenuItem(
                        value: 'logout',
                        text: 'Çıkış Yap',
                        icon: Icons.home,
                        isDestructive: true,
                      ),
                    ])
              ])
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, ThemeSize.appBarHeight);
}
