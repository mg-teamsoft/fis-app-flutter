part of '../../page/receipt_detail.dart';

final class _ReceiptDetailImagePlaceholder extends StatelessWidget {
  const _ReceiptDetailImagePlaceholder({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.1,
          ),
          Icon(
            Icons.image_not_supported_outlined,
            size: ThemeSize.avatarLarge,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
