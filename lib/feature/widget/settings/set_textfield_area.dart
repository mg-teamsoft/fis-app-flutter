part of '../../page/settings_page.dart';

final class _SettingsTextFieldArea extends StatelessWidget {
  const _SettingsTextFieldArea({
    required this.minLimitController,
    required this.maxLimitController,
    required this.monthlyTargetController,
  });

  final TextEditingController minLimitController;
  final TextEditingController maxLimitController;
  final TextEditingController monthlyTargetController;

  final String _moneyUnit = '₺ ';

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: ThemeSize.spacingM,
      children: [
        TextField(
          controller: minLimitController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          decoration: InputDecoration(
            prefixText: _moneyUnit,
            labelText: 'Minimum Tutar Limiti',
            border: const OutlineInputBorder(),
          ),
        ),
        TextField(
          controller: maxLimitController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          decoration: InputDecoration(
            prefixText: _moneyUnit,
            labelText: 'Maksimum Tutar Limiti',
            border: const OutlineInputBorder(),
          ),
        ),
        TextField(
          controller: monthlyTargetController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          decoration: InputDecoration(
            labelText: 'Aylık Hedef Tutarı',
            prefixText: _moneyUnit,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
