part of 'appbar.dart';

class _NotificationButton extends StatefulWidget {
  const _NotificationButton();

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  int _index = 0;
  late Color _currentColor;
  late IconData _currentIcon;
  late NotificationService _service;

  @override
  void initState() {
    super.initState();
    _service = NotificationService();

    _currentIcon = Icons.notifications;
    _currentColor = Colors.grey;

    unawaited(_getNotification());
  }

  Future<void> _getNotification() async {
    final notifications = await _service.fetchNotifications();
    final newIndex = notifications.length;
    if (!mounted) return;
    setState(() {
      _index = newIndex;
      if (_index == 0) {
        _currentIcon = Icons.notifications;
        _currentColor = context.colorScheme.onSurface;
      } else {
        _currentIcon = Icons.notifications_active;
        _currentColor = context.colorScheme.onSurface;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _index == 0
        ? _iconbutton()
        : Badge(
            label: ThemeTypography.labelSmall(context, _index.toString()),
            backgroundColor: context.theme.error,
            child: _iconbutton(),
          );
  }

  Widget _iconbutton() {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/notification'),
      child: Icon(
        _currentIcon,
        color: _currentColor,
        size: ThemeSize.iconMedium,
      ),
    );
  }
}
