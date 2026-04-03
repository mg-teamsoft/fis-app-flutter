import 'dart:io';

import 'package:fis_app_flutter/app/import/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

abstract class PlatformInit {
  Future<void> prepare();
}

class _MobileInit implements PlatformInit {
  @override
  Future<void> prepare() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
      ),
    );
  }
}

class _WebInit implements PlatformInit {
  @override
  Future<void> prepare() async {
    usePathUrlStrategy();
  }
}

class _DesktopInit implements PlatformInit {
  @override
  Future<void> prepare() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: 'Fis App',
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

class PlatformFactory {
  static PlatformInit getPlatformInit() {
    if (kIsWeb) {
      return _WebInit();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return _MobileInit();
    }
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return _DesktopInit();
    }
    return _MobileInit();
  }
}
