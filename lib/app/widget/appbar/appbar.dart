import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/widget/popmenu.dart';
import 'package:fis_app_flutter/app/widget/popmenuitem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part '../../enum/notification.dart';
part '../../model/notification.dart';
part './notification_button.dart';
part 'notification_card.dart';

class WidgetAppbar extends StatelessWidget implements PreferredSizeWidget {
  const WidgetAppbar({
    required this.showBackButton,
    required this.onSelected,
    super.key,
  });

  final bool showBackButton;
  final void Function(String)? onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(color: context.colorScheme.surface, boxShadow: [
        BoxShadow(
          color: context.colorScheme.onSurface,
          blurRadius: 0.3,
          spreadRadius: 0.3,
        )
      ]),
      child: SafeArea(
        child: Padding(
          padding: const ThemePadding.horizontalSymmetricMedium(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBackButton)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: context.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              else
                WidgetPopMenu(
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
              Image.asset(
                'assets/icon/RBGAppIcon.png',
                height: ThemeSize.iconLarge,
                width: ThemeSize.iconLarge,
              ),
              Row(
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
                  _NotificationButton(
                    /// TODO: Notification bağlanacak.
                    /// const durum sonlandırılacak.
                    /// kullanıcıların okuduğu notları read yapma func gerek
                    list: [
                      _ModelNotification(
                        title: 'Bildirim 1',
                        summary: 'Bu bir bildirimdir.',
                        date: DateTime.now(),
                        enumNotification: _EnumNotification.info,
                        isRead: false,
                        description: '',
                      ),
                      _ModelNotification(
                        title: 'Bildirim 2',
                        summary: 'Bu bir bildirimdir.',
                        date: DateTime.now(),
                        enumNotification: _EnumNotification.warning,
                        isRead: false,
                        description: '',
                      ),
                      _ModelNotification(
                        title: 'Bildirim 3',
                        summary: 'Bu bir bildirimdir.',
                        date: DateTime.now(),
                        enumNotification: _EnumNotification.error,
                        isRead: false,
                        description: '',
                      ),
                      _ModelNotification(
                        title: 'Bildirim 4',
                        summary: 'Bu bir bildirimdir.',
                        date: DateTime.now(),
                        enumNotification: _EnumNotification.success,
                        isRead: false,
                        description: '',
                      ),
                    ],
                    onClearAll: () {},
                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, ThemeSize.appBarHeight);
}
