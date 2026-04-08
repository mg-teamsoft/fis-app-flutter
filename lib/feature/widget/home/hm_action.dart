part of '../../page/home_page.dart';

final class _HomeActions extends StatelessWidget {
  const _HomeActions({required this.size});
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return TwiceButton(
      size: size!,
      onPressedOne: () => Navigator.of(context).pushNamed('/receipt'),
      onPressedTwo: () => Navigator.of(context).pushNamed('/excelFiles'),
      titleOne: ' Fiş Yükle',
      titleTwo: ' Excel Aç',
      iconOne: Icon(
        Icons.receipt,
        color: context.colorScheme.onPrimaryContainer,
        size: ThemeSize.iconMedium,
      ),
      iconTwo: Icon(
        Icons.table_chart,
        color: context.colorScheme.onPrimaryContainer,
        size: ThemeSize.iconMedium,
      ),
      textStyle: context.textTheme.bodyLarge,
      backgroundColorTwo: context.theme.success,
    );
  }
}
