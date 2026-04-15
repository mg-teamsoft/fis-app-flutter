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
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.surface,
            padding: const ThemePadding.verticalSymmetricMedium(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: ThemeTypography.bodyLarge(context, processButtonLabel),
        ),
        SizedBox(
          height: size.height * 0.03,
        ),
      ],
    );
  }
}
