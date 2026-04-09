import 'dart:async';

import 'package:fis_app_flutter/app/import/app.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/notification_service.dart';
import 'package:fis_app_flutter/model/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bildirimler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Text(
                        'Bildirimler yüklenemedi: $_error',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _notifications.isEmpty
                      ? const Center(child: Text('Bildirim bulunamadı.'))
                      : ListView.separated(
                          itemCount: _notifications.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey.shade200),
                          itemBuilder: (context, index) {
                            final notif = _notifications[index];
                            final isUnread = notif.isUnread;

                            return InkWell(
                              onTap: () => _handleNotificationTap(notif),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(
                                        top: 6,
                                        right: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isUnread
                                            ? Colors.blue
                                            : Colors.transparent,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ThemeTypography.h4(
                                            context,
                                            notif.title,
                                            color:
                                                context.colorScheme.onSurface,
                                            weight: FontWeight.w800,
                                          ),
                                          const SizedBox(height: 4),
                                          if (notif.subtitle != null)
                                            ThemeTypography.titleSmall(
                                              context,
                                              notif.subtitle ?? '',
                                              color: Colors.grey.shade600,
                                            )
                                          else
                                            const SizedBox.shrink(),
                                          if (notif.content.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            ThemeTypography.bodySmall(
                                              context,
                                              notif.content,
                                              color: Colors.grey.shade800,
                                            ),
                                          ],
                                          if (notif.time.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            ThemeTypography.bodySmall(
                                              context,
                                              notif.time,
                                              color: Colors.grey.shade600,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
