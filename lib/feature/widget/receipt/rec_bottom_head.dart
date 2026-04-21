part of '../../page/receipt_page.dart';

class _ReceiptBottomHead extends StatelessWidget {
  const _ReceiptBottomHead({
    required this.picked,
    required this.bytesCache,
    required this.processButtonLabel,
    required this.processSelected,
    required this.size,
  });

  final List<XFile> picked;
  final Map<String, Future<Uint8List>> bytesCache;
  final String processButtonLabel;
  final VoidCallback processSelected;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: picked.isEmpty ? null : processSelected,
            style: ElevatedButton.styleFrom(
              fixedSize:
                  const Size(double.infinity, ThemeSize.buttonHeightLarge),
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimaryContainer,
              disabledBackgroundColor:
                  context.colorScheme.primary.withValues(alpha: 0.2),
              disabledForegroundColor: context.colorScheme.onPrimaryContainer,
              padding: const ThemePadding.verticalSymmetricMedium(),
              shape: RoundedRectangleBorder(
                borderRadius: ThemeRadius.circular8,
              ),
            ),
            child: ThemeTypography.bodyMedium(context, processButtonLabel),
          ),
        ),
      ],
    );
  }
}
