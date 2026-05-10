part of '../../page/about_page.dart';

class _AboutFeatureTile extends StatelessWidget {
  const _AboutFeatureTile({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const ThemePadding.marginBottom10(),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: ThemeRadius.circular12,
            ),
            padding: const ThemePadding.all10(),
            child: Icon(
              icon,
              color: context.colorScheme.onPrimaryContainer,
              size: ThemeSize.iconLarge,
            ),
          ),
          const SizedBox(width: ThemeSize.spacingM),
          Expanded(
            child: ThemeTypography.bodyMedium(
              context,
              text,
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
