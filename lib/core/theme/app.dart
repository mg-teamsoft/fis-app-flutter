import 'package:fis_app_flutter/core/theme/extension.dart';
import 'package:fis_app_flutter/core/theme/scheme.dart';
import 'package:flutter/material.dart';

final class ThemeApp {
  ThemeApp._();

  static final ColorScheme _darkscheme = ThemeColorScheme.dark;
  static final ColorScheme _lightscheme = ThemeColorScheme.light;

  static final String _fontFamily = 'Manrope';

  static final ThemeData _light = ThemeData(
    useMaterial3: true,
    colorScheme: _lightscheme,
    textTheme: const TextTheme().apply(
      bodyColor: _lightscheme.onSurface,
      displayColor: _lightscheme.onSurface,
    ),
    fontFamily: _fontFamily,
    extensions: <ThemeExtension<dynamic>>[
      AppThemeExtension.light,
    ],
  );

  static final ThemeData _dark = ThemeData(
    useMaterial3: true,
    colorScheme: _darkscheme,
    textTheme: TextTheme().apply(
      bodyColor: _darkscheme.onSurface,
      displayColor: _darkscheme.onSurface,
    ),
    fontFamily: _fontFamily,
    extensions: <ThemeExtension<dynamic>>[
      AppThemeExtension.dark,
    ],
  );

  // GET FunctionsR
  static ThemeData get light => _light;
  static ThemeData get dark => _dark;
}
