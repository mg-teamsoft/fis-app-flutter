import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/widget/popmenu.dart';
import 'package:fis_app_flutter/app/widget/popmenuitem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part '../enum/notification.dart';
part 'notification_button.dart';

class WidgetAppbar extends StatelessWidget implements PreferredSizeWidget {
  const WidgetAppbar({
    required this.showBackButton,
    required this.onSelected,
    this.onBackPressed,
    super.key,
  });

  final bool showBackButton;
  final void Function(String)? onSelected;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface,
            blurRadius: 0.3,
            spreadRadius: 0.3,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const ThemePadding.horizontalSymmetricMedium(),
          child: Stack(
            children: [
              Positioned.fill(
                // left area
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: showBackButton
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: context.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            if (onBackPressed != null) {
                              onBackPressed?.call();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        )
                      : WidgetPopMenu(
                          onSelected: onSelected,
                          icon: Icons.menu_rounded,
                          menuitems: [
                            WidgetPopMenuItem(
                              value: '/home',
                              text: 'Anasayfa',
                              icon: Icons.home,
                            ),
                            WidgetPopMenuItem(
                              value: '/gallery',
                              text: 'Fişler',
                              icon: Icons.receipt,
                            ),
                            WidgetPopMenuItem(
                              value: '/group',
                              text: 'Kişiler',
                              icon: Icons.group,
                            ),
                            WidgetPopMenuItem(
                              value: '/settings',
                              text: 'Ayarlar',
                              icon: Icons.settings,
                            ),
                          ],
                        ),
                ),
              ),

              // center area
              Positioned.fill(
                child: Image.asset(
                  'assets/icon/RBGAppIcon.png',
                  height: ThemeSize.iconMedium,
                  width: ThemeSize.iconMedium,
                ),
              ),

              // right area
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDark
                            ? Colors.orangeAccent
                            : context.colorScheme.onSurface,
                        size: ThemeSize.iconMedium,
                      ),
                      onPressed: () {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                    ),
                    const _NotificationButton(),
                    WidgetPopMenu(
                      onSelected: onSelected,
                      icon: Icons.person_pin,
                      menuitems: [
                        WidgetPopMenuItem(
                          value: '/about',
                          text: 'Hakkında',
                          icon: Icons.question_mark_outlined,
                        ),
                        WidgetPopMenuItem(
                          value: '/accountSettings',
                          text: 'Hesap Ayarları',
                          icon: Icons.settings,
                        ),
                        WidgetPopMenuItem(
                          value: 'logout',
                          text: 'Çıkış Yap',
                          icon: Icons.logout,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, ThemeSize.appBarHeight);
}
