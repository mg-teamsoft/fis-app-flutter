part of '../../page/receipt_manuel_page.dart';

class _ReceiptManuelHelperHint extends StatelessWidget {
  const _ReceiptManuelHelperHint({
    required this.fieldsEnabled,
    required this.isUploading,
  });

  final bool fieldsEnabled;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!fieldsEnabled && !isUploading) ...[
          const SizedBox(height: ThemeSize.spacingS),
          Container(
            width: double.infinity,
            padding: const ThemePadding.horizontalSymmetricMedium(),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainer,
              borderRadius: ThemeRadius.circular12,
              border: Border.all(color: context.theme.warning),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: context.theme.warning, size: ThemeSize.iconMedium),
                const SizedBox(width: ThemeSize.spacingS),
                Expanded(
                  child: ThemeTypography.labelLarge(
                    context,
                    'Formu doldurmak için önce fiş görselini yükleyin.',
                    color: context.theme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: ThemeSize.spacingXl),
      ],
    );
  }
}
