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
                          separatorBuilder: (context, index) =>
                              Divider(color: context.colorScheme.outline),
                          itemBuilder: (context, index) {
                            if (index == notifications.length) {
                              return const Padding(
                                padding: ThemePadding.all16(),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            final notif = notifications[index];
                            final isUnread = notif.isUnread;

                            return InkWell(
                              onTap: () => handleNotificationTap(notif),
                              child: Padding(
                                padding: const ThemePadding
                                    .horizontalSymmetricMedium(),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin:
                                          ThemePadding.verticalSymmetricFree(
                                              12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isUnread
                                            ? context.colorScheme.primary
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
                                              color:
                                                  context.colorScheme.outline,
                                              weight: FontWeight.w400,
                                            )
                                          else
                                            const SizedBox.shrink(),
                                          if (notif.content.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            ThemeTypography.bodySmall(
                                              context,
                                              notif.content,
                                              color:
                                                  context.colorScheme.outline,
                                              weight: FontWeight.w600,
                                            ),
                                          ],
                                          if (notif.time.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            ThemeTypography.bodySmall(
                                              context,
                                              notif.time,
                                              color:
                                                  context.colorScheme.outline,
                                              weight: FontWeight.w700,
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
