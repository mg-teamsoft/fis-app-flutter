import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppThemeButton extends StatelessWidget {
  const AppThemeButton({super.key,});

  

  @override
  Widget build(BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
    return  IconButton(
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: isDark
                              ? context.theme.warning
                              : context.colorScheme.onSurface,
                          size: ThemeSize.iconMedium,
                        ),
                        onPressed: () {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                      );
  }
}
