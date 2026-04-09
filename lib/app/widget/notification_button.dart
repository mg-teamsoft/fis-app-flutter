part of 'appbar.dart';

class _NotificationButton extends StatefulWidget {
  const _NotificationButton();

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  int _index = 0;
  Color _currentColor = Colors.transparent;
  IconData _currentIcon = Icons.notifications;
  late NotificationService _service;

  @override
  void initState() {
    super.initState();
    _service = NotificationService();
    unawaited(_getNotification());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _updateState();
  }

  void _updateState() {
    if (!mounted) return;
    setState(() {
      if (_index == 0) {
        _currentIcon = Icons.notifications;
        _currentColor = context.colorScheme.onSurface;
      } else {
        _currentIcon = Icons.notifications_active;
        _currentColor = context.colorScheme.primary;
      }
    });
  }

  Future<void> _getNotification() async {
    try {
      final notifications = await _service.fetchNotifications();
      if (!mounted) return;

      _index = notifications.length;

      _updateState();
    } on Exception catch (e) {
      debugPrint('Notification Error: $e');
    }
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
