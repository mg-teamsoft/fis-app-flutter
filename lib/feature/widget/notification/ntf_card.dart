part of '../../page/notification_page.dart';

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _expanded = false;
  NotificationModel get notification => widget.notification;

  (String, IconData, Color) _category(ColorScheme colors) {
    return switch (notification.category) {
      'campaign' => ('Kampanya', Icons.campaign_rounded, colors.secondary),
      'version' => (
          'Sürüm Güncelleme',
          Icons.system_update_rounded,
          colors.primary
        ),
      'news' => ('Haber', Icons.newspaper_rounded, colors.tertiary),
      'contactNotes' => (
          'Kontak Kişisi',
          Icons.person_outline_rounded,
          colors.secondary
        ),
      _ => ('Bildirim', Icons.notifications_outlined, colors.primary),
    };
  }

  String? _remainingTime() {
    if (notification.category != 'campaign') return null;
    final end = notification.endDate;
    if (end == null) return null;
    final remaining = end.difference(DateTime.now());
    if (remaining <= Duration.zero) return 'Süresi doldu';
    if (remaining.inHours < 1) return 'Son 1 saat';
    if (remaining.inHours < 24) return 'Kalan süre: ${remaining.inHours} saat';
    return 'Kalan süre: ${(remaining.inHours / 24).ceil()} gün';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final (label, icon, accent) = _category(colors);
    final unread = notification.isUnread;
    final remaining = _remainingTime();
    final version = notification.version?.trim();
    final summary = notification.subtitle?.trim() ?? '';
    final content = notification.content.trim();
    final background = unread
        ? Color.alphaBlend(
            colors.primary.withValues(alpha: 0.08),
            colors.surface,
          )
        : colors.surfaceContainerLowest;

    Widget badge(String text, Color color) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

    return Semantics(
      label: unread ? 'Okunmamış bildirim' : 'Okunmuş bildirim',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: unread ? accent : accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child:
                          Icon(icon, color: unread ? colors.surface : accent),
                    ),
                    if (unread)
                      Positioned(
                        top: -3,
                        left: -3,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: background, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          badge(label, accent),
                          if (version != null && version.isNotEmpty)
                            badge(version, colors.primary),
                          if (remaining != null)
                            badge(remaining, colors.tertiary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.title,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight:
                              unread ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      if (summary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          summary,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (notification.time.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          notification.time,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          iconAlignment: IconAlignment.end,
                          onPressed: () =>
                              setState(() => _expanded = !_expanded),
                          icon: Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          label: Text(
                            _expanded ? 'Detayları Gizle' : 'Detayları Gör',
                          ),
                        ),
                        if (_expanded)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              content,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: unread ? 'Okumak için dokunun' : 'Okundu',
                  child: Icon(
                    unread ? Icons.check_circle_outline : Icons.check_circle,
                    size: 20,
                    color: unread ? colors.outline : colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
