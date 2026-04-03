import 'dart:async';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/settings_service.dart';
import 'package:fis_app_flutter/app/widget/checkbox_tile.dart';
import 'package:fis_app_flutter/model/receipt_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

part '../controller/settings.dart';
part '../view/settings.dart';
part '../widget/settings/checkbox_tile_area.dart';
part '../widget/settings/header.dart';
part '../widget/settings/save_button.dart';
part '../widget/settings/textfield_area.dart';
part '../widget/settings/transaction.dart';

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
