part of '../page/notification_page.dart';

mixin _NotificationController on State<PageNotification> {
  late final NotificationService _notificationService;
  late bool _isLoading;
  late String? _error;
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _isLoading = true;
    _error = null;
    _notifications = [];
    unawaited(_loadNotifications());
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _notificationService.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    if (!notification.isUnread || notification.id.trim().isEmpty) {
      return;
    }

    try {
      await _notificationService.markAsRead([notification.id]);
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map(
              (item) => item.id == notification.id
                  ? item.copyWith(isUnread: false)
                  : item,
            )
            .toList();
      });
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }
}
