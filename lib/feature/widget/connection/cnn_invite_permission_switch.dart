part of '../../page/connection_page.dart';

class _CnnInvitePermissionSwitch extends StatelessWidget {
  const _CnnInvitePermissionSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular8,
        border: Border.all(color: context.theme.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: ThemeTypography.bodySmall(context, label,
                weight: FontWeight.w500, color: context.colorScheme.onSurface),
          ),
          const SizedBox(height: ThemeSize.spacingXs),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              return context.colorScheme.surface;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return context.colorScheme.primary;
              }
              return context.theme.divider;
            }),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
              return Colors.transparent;
            }),
          ),
        ],
      ),
    );
  }
}
