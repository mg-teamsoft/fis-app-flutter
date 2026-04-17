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
        const SizedBox(height: 12),
        Text(
          'Diğer Alanlar',
          style: context.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            kv.key,
                            style: context.textTheme.labelMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            kv.value?.toString() ?? '—',
                            style: context.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
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
