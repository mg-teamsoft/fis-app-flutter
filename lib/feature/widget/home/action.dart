part of '../../page/home.dart';

final class _HomeActions extends StatelessWidget {
  const _HomeActions({required this.size});
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return TwiceButton(
      size: size!,
      onPressedOne: () => Navigator.of(context).pushNamed('/excel'),
      onPressedTwo: () => Navigator.of(context).pushNamed('/receipt'),
      titleOne: 'Fiş Yükle',
      titleTwo: 'Excel Görüntüle',
      iconOne: SvgPicture.asset('assets/svg/receipt.svg'),
      iconTwo: SvgPicture.asset('assets/svg/excel.svg'),
      textStyle: context.textTheme.bodyLarge,
      backgroundColorTwo: context.theme.success,
    );
  }
}
