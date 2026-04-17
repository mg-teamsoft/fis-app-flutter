part of '../../page/notification_page.dart';

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return ThemeTypography.h4(
      context,
      text,
      weight: FontWeight.w700,
      color: context.colorScheme.onSurface,
      textAlign: TextAlign.center,
    );
  }
}
