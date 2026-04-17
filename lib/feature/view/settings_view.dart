part of '../page/settings_page.dart';

final class _SettingsView extends StatelessWidget {
  const _SettingsView({
    required this.moneyUnit,
    required VoidCallback onChanged,
    required this.settingsService,
    required this.minLimitController,
    required this.maxLimitController,
    required this.monthlyTargetController,
    required this.food,
    required this.meal,
    required this.fuel,
    required this.parking,
    required this.electronic,
    required this.medication,
    required this.stationery,
    required this.makeup,
    required this.saving,
    required this.hasChanges,
    required this.suppressChanges,
    required this.loading,
    required this.saveSettings,
  }) : _onChanged = onChanged;

  final SettingsService settingsService;
  final TextEditingController minLimitController;
  final TextEditingController maxLimitController;
  final TextEditingController monthlyTargetController;
  final String moneyUnit;

  final bool food;
  final bool meal;
  final bool fuel;
  final bool parking;
  final bool electronic;
  final bool medication;
  final bool stationery;
  final bool makeup;

  final bool loading;
  final bool saving;
  final bool hasChanges;
  final bool suppressChanges;

  final Future<void> Function() saveSettings;
  final VoidCallback _onChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView(
        padding: const ThemePadding.all20(),
        children: [
          const _SettingsHeader(),
          const SizedBox(height: ThemeSize.spacingL),
          Text(
            'Fişler için minimum ve maksimum tutarları ayarlayın.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: ThemeSize.spacingM),
          _SettingsTextFieldArea(
            moneyUnit: moneyUnit,
            minLimitController: minLimitController,
            maxLimitController: maxLimitController,
            monthlyTargetController: monthlyTargetController,
          ),
          const SizedBox(height: ThemeSize.spacingXl),
          const _SettingsTransaction(),
          const SizedBox(height: ThemeSize.spacingM),
          _SettingsCheckBoxTileArea(
            onChanged: _onChanged,
            food: food,
            meal: meal,
            fuel: fuel,
            parking: parking,
            electronic: electronic,
            medication: medication,
            stationery: stationery,
            makeup: makeup,
          ),
          const SizedBox(height: ThemeSize.spacingXXl),
          _SettingsSaveButton(
            saving: saving,
            hasChanges: hasChanges,
            saveSettings: saveSettings,
          ),
        ],
      );
    }
  }
}
