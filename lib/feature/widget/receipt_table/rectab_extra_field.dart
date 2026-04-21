part of '../../page/receipt_table_page.dart';

class _ReceiptTableExtraField extends StatelessWidget {
  const _ReceiptTableExtraField({
    required this.extras,
  });

  final Map<String, dynamic>? extras;

  @override
  Widget build(BuildContext context) {
    if (extras == null || extras!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: ThemeSize.spacingM),
        ThemeTypography.titleSmall(
          context,
          'Diğer Alanlar',
          weight: FontWeight.w900,
          color: context.colorScheme.onSurface,
        ),
        const SizedBox(height: ThemeSize.spacingS),
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: ThemeRadius.circular12,
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Column(
            // .entries.map kullanımı asMap()'den daha temizdir
            children: extras!.entries.toList().asMap().entries.map((e) {
              final i = e.key;
              final kv = e.value;
              final isLast = i == extras!.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const ThemePadding.all10(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: ThemeSize.avatarXL,
                          child: Text(
                            kv.key,
                            style: context.textTheme.labelMedium,
                          ),
                        ),
                        const SizedBox(width: ThemeSize.spacingS),
                        Expanded(
                          child: ThemeTypography.bodyMedium(
                            context,
                            kv.value?.toString() ?? '—',
                            weight: FontWeight.w600,
                            color: context.colorScheme.onSurface,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 14,
                      endIndent: 14,
                      color: context.colorScheme.outlineVariant,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
