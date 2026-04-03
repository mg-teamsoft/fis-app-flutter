import 'package:fis_app_flutter/app/import/app.dart';

part './mixin.dart';

class AppConfigGeneral extends StatefulWidget {
  const AppConfigGeneral({super.key});

  @override
  State<AppConfigGeneral> createState() => _AppConfigGeneralState();
}

class _AppConfigGeneralState extends State<AppConfigGeneral>
    with _AppConfigMixin {
  @override
  Widget build(BuildContext context) {
    return ProviderGeneral(
      child: Builder(
        builder: (newContext) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Fiş App',
            theme: ThemeApp.light,
            darkTheme: ThemeApp.dark,
            themeMode: newContext.watch<ThemeProvider>().themeMode,
            localizationsDelegates: _localization.delegate,
            supportedLocales: _localization.supportLocales,
            navigatorKey: AuthNavigation.navigatorKey,
            initialRoute: _router.initialRoute,
            routes: _router.routes,
            onGenerateRoute: (settings) {
              final uri = Uri.tryParse(settings.name ?? '');
              if (uri != null && uri.path == '/resetPassword') {
                final token = uri.queryParameters['token'] ??
                    (settings.arguments as String?);
                return MaterialPageRoute(
                  builder: (_) => ResetPasswordPage(initialToken: token),
                  settings: settings,
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
