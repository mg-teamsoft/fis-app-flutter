part of 'appbar.dart';

class _NotificationButton extends StatefulWidget {
  const _NotificationButton();

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  late int _index;
  late Color _currentColor;
  late IconData _currentIcon;
  // add notification service

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getNotification();
  }

  void _getNotification() {
    setState(() {
      _index = 1;
    });
    if (_index == 0) {
      _currentIcon = Icons.notifications;
      _currentColor = context.colorScheme.onSurface.withValues(alpha: 0.5);
    } else {
      _currentIcon = Icons.notifications_active;
      _currentColor = context.colorScheme.onSurface;
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
