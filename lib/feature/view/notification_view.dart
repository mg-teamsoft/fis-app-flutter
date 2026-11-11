part of '../page/notification_page.dart';

class _NotificationView extends StatelessWidget {
  const _NotificationView({
    required this.handleNotificationTap,
    required this.service,
    required this.isLoading,
    required this.isLoadingMore,
    required this.scrollController,
    required this.notifications,
    required this.error,
  });

  final NotificationService service;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<NotificationModel> notifications;
  final Future<void> Function(NotificationModel) handleNotificationTap;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: ThemeSize.spacingXs),
        const _NotificationHeader(text: 'Bildirimler'),
        const SizedBox(height: ThemeSize.spacingM),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(
                      child: ThemeTypography.bodySmall(
                        context,
                        'Bildirimler yüklenemedi: $error',
                        textAlign: TextAlign.center,
                        color: context.colorScheme.error,
                      ),
                    )
                  : notifications.isEmpty
                      ? Center(
                          child: ThemeTypography.bodyLarge(
                            context,
                            'Bildirim bulunamadı.',
                            color: context.colorScheme.onSurface,
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount:
                              notifications.length + (isLoadingMore ? 1 : 0),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == notifications.length) {
                              return const Padding(
                                padding: ThemePadding.all16(),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            final notification = notifications[index];
                            return _NotificationCard(
                              key: ValueKey(notification.id),
                              notification: notification,
                              onTap: () => handleNotificationTap(notification),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
