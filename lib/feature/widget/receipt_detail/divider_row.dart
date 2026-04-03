part of '../../page/receipt_detail.dart';

final class _DividerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: context.colorScheme.onSurface,
        height: 1,
      ),
    );
  }
}
