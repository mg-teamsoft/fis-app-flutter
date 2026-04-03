part of './appbar.dart';

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.model, required this.size});

  final _ModelNotification model;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final iconColor = context.colorScheme.onSurface;
    final Color bg;
    final IconData icon;

    switch (model.enumNotification) {
      case _EnumNotification.error:
        bg = context.theme.error;
        icon = Icons.error;

      case _EnumNotification.warning:
        bg = context.theme.warning;
        icon = Icons.warning;

      case _EnumNotification.info:
        bg = context.theme.info;
        icon = Icons.info;

      case _EnumNotification.success:
        bg = context.theme.success;
        icon = Icons.check;

      case _EnumNotification.none:
        bg = context.theme.divider;
        icon = Icons.code_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(ThemeSize.spacingXs),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.9),
        borderRadius: ThemeRadius.circular12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: ThemeSize.iconSmall, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  model.title,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${model.date.hour}:${model.date.minute.toString().padLeft(2, '0')}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              model.summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
