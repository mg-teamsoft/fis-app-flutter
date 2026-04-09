part of '../page/notification_page.dart';

class _NotificationView extends StatelessWidget {
  const _NotificationView({
    required this.handleNotificationTap,
    required this.service,
    required this.isLoading,
    required this.notifications,
    required this.error,
  });

  final NotificationService service;
  final bool isLoading;
  final String? error;
  final List<NotificationModel> notifications;
  final Future<void> Function(NotificationModel) handleNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _NotificationHeader(text: 'Bildirimler'),
        const SizedBox(height: 16),
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
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey.shade200),
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            final isUnread = notif.isUnread;

                            return InkWell(
                              onTap: () => handleNotificationTap(notif),
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
