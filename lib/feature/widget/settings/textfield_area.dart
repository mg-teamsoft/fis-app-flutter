part of '../../page/settings.dart';

final class _SettingsTextFieldArea extends StatelessWidget {
  const _SettingsTextFieldArea({
    required this.minLimitController,
    required this.maxLimitController,
    required this.monthlyTargetController,
  });

  final TextEditingController minLimitController;
  final TextEditingController maxLimitController;
  final TextEditingController monthlyTargetController;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: ThemeSize.spacingM,
      children: [
        TextField(
          controller: minLimitController,
          decoration: const InputDecoration(
            labelText: 'Minimum Tutar Limiti',
            border: OutlineInputBorder(),
          ),
        ),
        TextField(
          controller: maxLimitController,
          decoration: const InputDecoration(
            labelText: 'Maksimum Tutar Limiti',
            border: OutlineInputBorder(),
          ),
        ),
        TextField(
          controller: monthlyTargetController,
          decoration: const InputDecoration(
            labelText: 'Aylık Hedef Tutarı',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
