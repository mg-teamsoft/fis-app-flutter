part of '../../page/connection_page.dart';

class _CnnInviteMetaItem extends StatelessWidget {
  const _CnnInviteMetaItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThemeTypography.labelSmall(
          context,
          label,
          color: context.colorScheme.onSurface,
          weight: FontWeight.w700,
        ),
        const SizedBox(height: 4),
        ThemeTypography.bodySmall(
          context,
          value,
          color: valueColor ?? context.colorScheme.onSurface,
          weight: FontWeight.w700,
        ),
      ],
    );
  }
}
