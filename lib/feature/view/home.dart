part of '../page/home.dart';

final class _HomeView extends StatelessWidget {
  const _HomeView({required this.model, required this.size});

  final ModelHome model;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: ThemeSize.spacingL,
      children: [
        _HomeHeader(model: model),
        _HomeActions(
          size: size,
        ),
        _HomeRecentReceipts(model: model)
      ],
    );
  }
}
