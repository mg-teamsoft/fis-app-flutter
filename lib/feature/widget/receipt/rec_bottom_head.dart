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
    return Column(
      children: [
        ElevatedButton(
          onPressed: picked.isEmpty ? null : processSelected,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.secondary,
            foregroundColor: context.colorScheme.onSecondary,
            padding: const ThemePadding.verticalSymmetricMedium(),
            textStyle: ThemeTypography.bodyLarge(
              context,
              '',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).style,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(processButtonLabel),
        ),
        SizedBox(
          height: size.height * 0.03,
        ),
      ],
    );
  }
}
