import 'dart:async';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/settings_service.dart';
import 'package:fis_app_flutter/app/widget/checkbox_tile.dart';
import 'package:fis_app_flutter/model/receipt_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

part '../controller/settings_controller.dart';
part '../view/settings_view.dart';
part '../widget/settings/set_checkbox_tile_area.dart';
part '../widget/settings/set_header.dart';
part '../widget/settings/set_save_button.dart';
part '../widget/settings/set_textfield_area.dart';
part '../widget/settings/set_transaction.dart';

final class PageSettings extends StatefulWidget {
  const PageSettings({super.key});

  @override
  State<PageSettings> createState() => _PageSettingsState();
}

final class _PageSettingsState extends State<PageSettings>
    with _ConnectionSettings {
  @override
  Widget build(BuildContext context) {
    return _SettingsView(
      moneyUnit: _moneyUnit,
      loading: _loading,
      settingsService: _settingsService,
      minLimitController: _minLimitController,
      maxLimitController: _maxLimitController,
      monthlyTargetController: _monthlyTargetController,
      food: _food,
      meal: _meal,
      fuel: _fuel,
      parking: _parking,
      electronic: _electronic,
      medication: _medication,
      stationery: _stationery,
      makeup: _makeup,
      saving: _saving,
      hasChanges: _hasChanges,
      suppressChanges: _suppressChanges,
      saveSettings: _saveSettings,
      onChanged: _onFormChanged,
    );
  }
}
