part of '../../page/receipt_detail_page.dart';

final class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.entries});

  final List<Widget> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: ThemeRadius.circular20,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.04),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const ThemePadding.horizontalSymmetric(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries,
        ),
      ),
    );
  }
}
