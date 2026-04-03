part of './appbar.dart';

class _NotificationButton extends StatefulWidget {
  const _NotificationButton({
    required this.list,
    required this.onClearAll,
  });

  final List<_ModelNotification> list;
  final VoidCallback onClearAll;

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  late Size _size;

  List<_ModelNotification> get _unreadList =>
      widget.list.where((e) => !e.isRead).toList();

  int get _unreadCount => _unreadList.length;

  int _getPriorityWeight(_EnumNotification type) {
    switch (type) {
      case _EnumNotification.error:
        return 0;
      case _EnumNotification.warning:
        return 1;
      case _EnumNotification.info:
        return 2;
      case _EnumNotification.success:
        return 3;
      case _EnumNotification.none:
        return 4;
    }
  }

  _EnumNotification get _priorityStatus {
    if (_unreadList.isEmpty) {
      return _EnumNotification.none;
    } else if (_unreadList
        .any((e) => e.enumNotification == _EnumNotification.error)) {
      return _EnumNotification.error;
    } else if (_unreadList
        .any((e) => e.enumNotification == _EnumNotification.warning)) {
      return _EnumNotification.warning;
    } else if (_unreadList
        .any((e) => e.enumNotification == _EnumNotification.info)) {
      return _EnumNotification.info;
    } else {
      return _EnumNotification.success;
    }
  }

  IconData get _currentIcon {
    final status = _priorityStatus;
    switch (status) {
      case _EnumNotification.error:
        return Icons.notification_important_rounded;
      case _EnumNotification.warning:
        return Icons.notifications_active;
      case _EnumNotification.info:
        return Icons.notifications_paused_rounded;
      case _EnumNotification.success:
        return Icons.edit_notifications_rounded;
      case _EnumNotification.none:
        return Icons.notifications_none_rounded;
    }
  }

  Color get _currentColor {
    final status = _priorityStatus;
    switch (status) {
      case _EnumNotification.error:
        return context.theme.error;
      case _EnumNotification.warning:
        return context.theme.warning;
      case _EnumNotification.info:
        return context.theme.info;
      case _EnumNotification.success:
        return context.theme.success;
      case _EnumNotification.none:
        return context.theme.divider;
    }
  }

  @override
  void didChangeDependencies() {
    _size = MediaQuery.of(context).size;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final sortedList = List<_ModelNotification>.from(widget.list)
      ..sort(
        (a, b) => _getPriorityWeight(a.enumNotification)
            .compareTo(_getPriorityWeight(b.enumNotification)),
      );

    final menuWidth = _size.width * 0.6;

    return PopupMenuButton<String>(
      enabled: widget.list.isNotEmpty,
      padding: EdgeInsets.zero,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: ThemeRadius.circular12),
      icon: Badge(
        label: Text(_unreadCount.toString()),
        isLabelVisible: _unreadCount > 0,
        child: Icon(
          _currentIcon,
          color: _currentColor,
          size: ThemeSize.iconMedium,
        ),
      ),
      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: _size.height * 0.45,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: _size.height * 0.35,
            width: menuWidth,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: sortedList.length,
              itemBuilder: (context, index) {
                return _NotificationCard(
                  model: sortedList[index],
                  size: _size,
                );
              },
            ),
          ),
        ),
        if (widget.list.isNotEmpty) ...[
          PopupMenuItem(
            enabled: false,
            height: 1,
            padding: EdgeInsets.zero,
            child: Divider(color: context.theme.divider, height: 1),
          ),
          PopupMenuItem(
            value: 'clear',
            onTap: widget.onClearAll,
            child: Center(
              child: Text(
                'Hepsini Okundu Yap',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
