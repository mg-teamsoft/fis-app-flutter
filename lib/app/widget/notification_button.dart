part of 'appbar.dart';

class _NotificationButton extends StatefulWidget {
  const _NotificationButton();

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  late NotificationService _service;

  @override
  void initState() {
    super.initState();
    _service = NotificationService();
    unawaited(_getNotification());
  }

  Future<void> _getNotification() async {
    try {
      await _service.fetchNotifications();
    } on Exception catch (e) {
      debugPrint('Notification Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _service.unreadCount,
      builder: (context, count, child) {
        final currentIcon = count == 0 ? Icons.notifications : Icons.notifications_active;
        final currentColor = count == 0 ? context.colorScheme.onSurface : context.colorScheme.primary;

        final badgeChild = InkWell(
          onTap: () => Navigator.of(context).pushNamed('/notification'),
          child: Icon(
            currentIcon,
            color: currentColor,
            size: ThemeSize.iconMedium,
          ),
        );

        return count == 0
            ? badgeChild
            : Badge(
                label: ThemeTypography.labelSmall(context, count.toString()),
                backgroundColor: context.theme.error,
                child: badgeChild,
              );
      },
    );
  }
}
