part of '../page/notification_page.dart';

mixin _NotificationController on State<PageNotification> {
  late final NotificationService _notificationService;
  late bool _isLoading;
  late String? _error;
  late final ScrollController scrollController;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    scrollController = ScrollController()..addListener(_onScroll);
    _isLoading = true;
    _error = null;
    _notifications = [];
    unawaited(_loadNotifications());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        unawaited(_loadMoreNotifications());
      }
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final notifications =
          await _notificationService.fetchNotifications(page: _currentPage);
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
        if (notifications.length < 10) {
          _hasMore = false;
        }
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final newNotifications =
          await _notificationService.fetchNotifications(page: nextPage);
      if (!mounted) return;
      setState(() {
        _currentPage = nextPage;
        _isLoadingMore = false;
        if (newNotifications.isEmpty) {
          _hasMore = false;
        } else {
          _notifications.addAll(newNotifications);
          if (newNotifications.length < 10) {
            _hasMore = false;
          }
        }
      });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    if (!notification.isUnread || notification.id.trim().isEmpty) {
      return;
    }

    // Optimistic UI update
    setState(() {
      _notifications = _notifications
          .map(
            (item) => item.id == notification.id
                ? item.copyWith(isUnread: false)
                : item,
          )
          .toList();
    });

    _notificationService.decrementUnreadCount();

    try {
      await _notificationService.markAsRead([notification.id]);
    } on Exception catch (e) {
      _notificationService.incrementUnreadCount();
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map(
              (item) => item.id == notification.id
                  ? item.copyWith(isUnread: true)
                  : item,
            )
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }
}
