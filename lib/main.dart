import 'dart:async';
import 'dart:developer' as developer;

import 'package:fis_app_flutter/app/config/general.dart';
import 'package:fis_app_flutter/app/config/platform.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// ✅ add these imports (adjust paths to your project)

Future<void> main() async {
  await initializeDateFormatting('tr_TR');
  FlutterError.onError = FlutterError.dumpErrorToConsole;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final platformSetup = PlatformFactory.getPlatformInit();
      await platformSetup.prepare();
      runApp(const AppConfigGeneral());
    },
    (error, stack) {
      developer.log('Uncaught: $error\n$stack');
    },
  );
}
