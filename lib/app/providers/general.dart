import 'package:fis_app_flutter/app/import/provider.dart';

class ProviderGeneral extends StatelessWidget {
  const ProviderGeneral({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ 1) Single ApiClient instance for the whole app
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),

        // ✅ 2) UserPlanProvider app-wide (uses the same ApiClient)
        ChangeNotifierProvider<UserPlanProvider>(
          create: (ctx) => UserPlanProvider(ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider<PurchaseProvider>(
          create: (ctx) => PurchaseProvider(
            PurchaseService(userPlanProvider: ctx.read<UserPlanProvider>()),
            ctx.read<UserPlanProvider>(),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        // You can add AuthProvider here too (recommended),
        // and any other global providers.
      ],
      child: child,
    );
  }
}
