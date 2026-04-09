import 'dart:async' show unawaited;

import 'package:fis_app_flutter/app/import/app.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/notification_service.dart';
import 'package:fis_app_flutter/model/notification_model.dart';

part '../controller/notification_controller.dart';
part '../view/notification_view.dart';
part '../widget/notification/ntf_header.dart';

class PageNotification extends StatefulWidget {
  const PageNotification({super.key});

  @override
  State<PageNotification> createState() => _PageNotificationState();
}

class _PageNotificationState extends State<PageNotification>
    with _NotificationController {
  @override
  Widget build(BuildContext context) {
    return _NotificationView(
      handleNotificationTap: _handleNotificationTap,
      service: _notificationService,
      isLoading: _isLoading,
      notifications: _notifications,
      error: _error,
    );
  }
}
