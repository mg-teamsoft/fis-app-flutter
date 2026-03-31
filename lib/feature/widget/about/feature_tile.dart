part of '../../page/about.dart';

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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon,
                color: context.colorScheme.onPrimaryContainer,
                size: ThemeSize.iconLarge),
          ),
          const SizedBox(width: ThemeSize.spacingM),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
