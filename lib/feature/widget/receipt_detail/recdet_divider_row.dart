part of '../../page/receipt_detail_page.dart';

final class _DividerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const ThemePadding.verticalSymmetricMedium(),
      child: Divider(
        color: context.colorScheme.onSurface,
        height: 1,
      ),
    );
  }
}
