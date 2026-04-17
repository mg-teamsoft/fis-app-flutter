part of '../../page/connection_page.dart';

class _CnnInviteSummaryCard extends StatelessWidget {
  const _CnnInviteSummaryCard({
    required this.pendingCount,
  });

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const ThemePadding.all16(),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeTypography.labelSmall(
            context,
            'ÖZET',
            color: context.colorScheme.onSurface,
            weight: FontWeight.w700,
          ),
          const SizedBox(height: ThemeSize.spacingXs),
          RichText(
            text: TextSpan(
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.primary,
              ),
              children: [
                TextSpan(text: '$pendingCount'),
                TextSpan(
                  text: ' Beklemede',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThemeSize.spacingXs),
          ThemeTypography.bodySmall(
            context,
            'Finansal danışmanlarınıza gönderilen davetiyeleri yönetin. İzinleri inceleyin ve durumu gerçek zamanlı olarak takip edin.',
            color: context.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
