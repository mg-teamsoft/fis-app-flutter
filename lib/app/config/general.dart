import 'package:fis_app_flutter/app/import/app.dart';
import 'package:fis_app_flutter/app/import/page.dart';

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
                    (settings.arguments is String
                        ? settings.arguments! as String
                        : null);

                final args = settings.arguments as Map<String, dynamic>?;
                final openInMainLayout = args?['init'] == true;

                if (openInMainLayout) {
                  return MaterialPageRoute(
                    builder: (_) =>
                        const MainLayout(initialRoute: '/resetPassword'),
                    settings: settings,
                  );
                }

                return MaterialPageRoute(
                  builder: (_) => PageResetPassword(initialToken: token),
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
