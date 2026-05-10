part of '../../page/receipt_process_page.dart';

class _ReceiptProcessFilledButton extends StatelessWidget {
  const _ReceiptProcessFilledButton({
    required this.processing,
    required this.process,
  });

  final bool processing;
  final VoidCallback process;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ThemeSize.buttonHeightLarge,
      child: FilledButton.icon(
        onPressed: processing ? null : process,
        style: FilledButton.styleFrom(
          fixedSize: const Size(double.infinity, ThemeSize.buttonHeightLarge),
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.onPrimary,
          padding: const ThemePadding.all15(),
          shape: RoundedRectangleBorder(
            borderRadius: ThemeRadius.circular12,
          ),
        ),
        icon: processing
            ? const SizedBox(
                height: ThemeSize.iconMedium,
                width: ThemeSize.iconMedium,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow),
        label: ThemeTypography.bodyLarge(
          context,
          processing ? 'İşleniyor...' : 'İşle',
          weight: FontWeight.w900,
          color: context.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
