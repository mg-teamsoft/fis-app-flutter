import 'package:fis_app_flutter/core/theme/color.dart';
import 'package:flutter/material.dart';

final class ThemeColorScheme {
  ThemeColorScheme._();

  static final ThemeColorPalette _palettelight = ThemeColors.light;
  static final ThemeColorPalette _palettedark = ThemeColors.dark;

  static final ColorScheme _light = ColorScheme.light(
    primary: _palettelight.primary,
    onPrimary: _palettelight.onPrimary,
    primaryContainer: _palettelight.primaryContainer,
    onPrimaryContainer: _palettelight.onPrimaryContainer,
    secondary: _palettelight.secondary,
    onSecondary: _palettelight.onSecondary,
    secondaryContainer: _palettelight.secondaryContainer,
    onSecondaryContainer: _palettelight.onSecondaryContainer,
    tertiary: _palettelight.tertilary,
    onTertiary: _palettelight.onTertilary,
    tertiaryContainer: _palettelight.tertilaryContainer,
    onTertiaryContainer: _palettelight.onTertilaryContainer,
    error: _palettelight.error,
    onError: _palettelight.onError,
    errorContainer: _palettelight.errorContainer,
    onErrorContainer: _palettelight.onErrorContainer,
    surface: _palettelight.surface,
    onSurface: _palettelight.onSurface,
    surfaceContainerHigh: _palettelight.surfaceContainerHigh,
    onSurfaceVariant: _palettelight.onSurfaceVariant,
    outline: _palettelight.outline,
    outlineVariant: _palettelight.outlineVariant,
  );

  static final ColorScheme _dark = ColorScheme.dark(
    primary: _palettedark.primary,
    onPrimary: _palettedark.onPrimary,
    primaryContainer: _palettedark.primaryContainer,
    onPrimaryContainer: _palettedark.onPrimaryContainer,
    secondary: _palettedark.secondary,
    onSecondary: _palettedark.onSecondary,
    secondaryContainer: _palettedark.secondaryContainer,
    onSecondaryContainer: _palettedark.onSecondaryContainer,
    tertiary: _palettedark.tertilary,
    onTertiary: _palettedark.onTertilary,
    tertiaryContainer: _palettedark.tertilaryContainer,
    onTertiaryContainer: _palettedark.onTertilaryContainer,
    error: _palettedark.error,
    onError: _palettedark.onError,
    errorContainer: _palettedark.errorContainer,
    onErrorContainer: _palettedark.onErrorContainer,
    surface: _palettedark.surface,
    onSurface: _palettedark.onSurface,
    surfaceContainerHigh: _palettedark.surfaceContainerHigh,
    onSurfaceVariant: _palettedark.onSurfaceVariant,
    outline: _palettedark.outline,
    outlineVariant: _palettedark.outlineVariant,
  );

  // GET Functions
  static ColorScheme get light => _light;
  static ColorScheme get dark => _dark;
}
