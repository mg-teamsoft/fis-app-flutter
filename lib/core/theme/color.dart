import 'dart:ui';

final class ThemeColors {
  ThemeColors._();

  // Light Colors (The Digital Vault-Atelier / Paper Strategy)
  static const Color _primaryLight = Color(0xff0052ae);
  static const Color _onPrimaryLight = Color(0xffffffff);
  static const Color _primaryContainerLight = Color(
    0xff0069dc,
  );
  static const Color _onPrimaryContainerLight = Color(0xffffffff);
  static const Color _secondaryLight = Color(
    0xffeff4ff,
  );
  static const Color _onSecondaryLight = Color(
    0xff121c2a,
  );
  static const Color _secondaryContainerLight = Color(
    0xffd9e3f6,
  );
  static const Color _onSecondaryContainerLight = Color(0xff121c2a);
  static const Color _tertilaryLight = Color(
    0xff993100,
  );
  static const Color _onTertilaryLight = Color(0xffffffff);
  static const Color _tertilaryContainerLight = Color(0xffd9e3f6);
  static const Color _onTertilaryContainerLight = Color(0xff121c2a);
  static const Color _errorLight = Color(0xff9B0F06);
  static const Color _onErrorLight = Color(0xffffffff);
  static const Color _errorContainerLight = Color(0xffFFDAD6);
  static const Color _onErrorContainerLight = Color(0xff410002);
  static const Color _surfaceLight = Color(
    0xfff8f9ff,
  );
  static const Color _onSurfaceLight = Color(
    0xff121c2a,
  );
  static const Color _surfaceContainerHighLight = Color(
    0xffd9e3f6,
  );
  static const Color _onSurfaceVariantLight = Color(
    0xff43474E,
  );
  static const Color _outlineLight = Color(0xff73777F);
  static const Color _outlineVariantLight = Color(
    0x26c4c5d9,
  );

  // Dark Colors (Midnight Vault / Deep Tones)
  static const Color _primaryDark = Color(0xffD1E4FF);
  static const Color _onPrimaryDark = Color(0xff002D5E);
  static const Color _primaryContainerDark = Color(0xff00497E);
  static const Color _onPrimaryContainerDark = Color(0xffD1E4FF);
  static const Color _secondaryDark = Color(0xff4ea3ea);
  static const Color _onSecondaryDark = Color(0xff000000);
  static const Color _secondaryContainerDark = Color(0xff00497E);
  static const Color _onSecondaryContainerDark = Color(0xffD1E4FF);
  static const Color _tertilaryDark = Color(0xffB7C9E2);
  static const Color _onTertilaryDark = Color(0xff213145);
  static const Color _tertilaryContainerDark = Color(0xff38475A);
  static const Color _onTertilaryContainerDark = Color(0xffD3E2F8);
  static const Color _errorDark = Color(0xffFFB4AB);
  static const Color _onErrorDark = Color(0xff9B0F06);
  static const Color _errorContainerDark = Color(0xff93000A);
  static const Color _onErrorContainerDark = Color(0xffFFDAD6);
  static const Color _surfaceDark = Color(0xff0B1018);
  static const Color _onSurfaceDark = Color(0xffE2E2E6);
  static const Color _surfaceContainerHighDark = Color(0xff1A202A);
  static const Color _onSurfaceVariantDark = Color(0xffC3C7CF);
  static const Color _outlineDark = Color(0xff8D9199);
  static const Color _outlineVariantDark = Color(0xffF6F7F8);

  static final ThemeColorPalette light = _LightColorPalette();
  static final ThemeColorPalette dark = _DarkColorPalette();
}

abstract class ThemeColorPalette {
  Color get primary;
  Color get onPrimary;
  Color get primaryContainer;
  Color get onPrimaryContainer;
  Color get secondary;
  Color get onSecondary;
  Color get secondaryContainer;
  Color get onSecondaryContainer;
  Color get tertilary;
  Color get onTertilary;
  Color get tertilaryContainer;
  Color get onTertilaryContainer;
  Color get error;
  Color get onError;
  Color get errorContainer;
  Color get onErrorContainer;
  Color get surface;
  Color get onSurface;
  Color get surfaceContainerHigh;
  Color get onSurfaceVariant;
  Color get outline;
  Color get outlineVariant;
}

class _LightColorPalette extends ThemeColorPalette {
  @override
  Color get primary => ThemeColors._primaryLight;
  @override
  Color get onPrimary => ThemeColors._onPrimaryLight;
  @override
  Color get primaryContainer => ThemeColors._primaryContainerLight;
  @override
  Color get onPrimaryContainer => ThemeColors._onPrimaryContainerLight;
  @override
  Color get secondary => ThemeColors._secondaryLight;
  @override
  Color get onSecondary => ThemeColors._onSecondaryLight;
  @override
  Color get secondaryContainer => ThemeColors._secondaryContainerLight;
  @override
  Color get onSecondaryContainer => ThemeColors._onSecondaryContainerLight;
  @override
  Color get tertilary => ThemeColors._tertilaryLight;
  @override
  Color get onTertilary => ThemeColors._onTertilaryLight;
  @override
  Color get tertilaryContainer => ThemeColors._tertilaryContainerLight;
  @override
  Color get onTertilaryContainer => ThemeColors._onTertilaryContainerLight;
  @override
  Color get error => ThemeColors._errorLight;
  @override
  Color get onError => ThemeColors._onErrorLight;
  @override
  Color get errorContainer => ThemeColors._errorContainerLight;
  @override
  Color get onErrorContainer => ThemeColors._onErrorContainerLight;
  @override
  Color get surface => ThemeColors._surfaceLight;
  @override
  Color get onSurface => ThemeColors._onSurfaceLight;
  @override
  Color get surfaceContainerHigh => ThemeColors._surfaceContainerHighLight;
  @override
  Color get onSurfaceVariant => ThemeColors._onSurfaceVariantLight;
  @override
  Color get outline => ThemeColors._outlineLight;
  @override
  Color get outlineVariant => ThemeColors._outlineVariantLight;
}

class _DarkColorPalette extends ThemeColorPalette {
  @override
  Color get primary => ThemeColors._primaryDark;
  @override
  Color get onPrimary => ThemeColors._onPrimaryDark;
  @override
  Color get primaryContainer => ThemeColors._primaryContainerDark;
  @override
  Color get onPrimaryContainer => ThemeColors._onPrimaryContainerDark;
  @override
  Color get secondary => ThemeColors._secondaryDark;
  @override
  Color get onSecondary => ThemeColors._onSecondaryDark;
  @override
  Color get secondaryContainer => ThemeColors._secondaryContainerDark;
  @override
  Color get onSecondaryContainer => ThemeColors._onSecondaryContainerDark;
  @override
  Color get tertilary => ThemeColors._tertilaryDark;
  @override
  Color get onTertilary => ThemeColors._onTertilaryDark;
  @override
  Color get tertilaryContainer => ThemeColors._tertilaryContainerDark;
  @override
  Color get onTertilaryContainer => ThemeColors._onTertilaryContainerDark;
  @override
  Color get error => ThemeColors._errorDark;
  @override
  Color get onError => ThemeColors._onErrorDark;
  @override
  Color get errorContainer => ThemeColors._errorContainerDark;
  @override
  Color get onErrorContainer => ThemeColors._onErrorContainerDark;
  @override
  Color get surface => ThemeColors._surfaceDark;
  @override
  Color get onSurface => ThemeColors._onSurfaceDark;
  @override
  Color get surfaceContainerHigh => ThemeColors._surfaceContainerHighDark;
  @override
  Color get onSurfaceVariant => ThemeColors._onSurfaceVariantDark;
  @override
  Color get outline => ThemeColors._outlineDark;
  @override
  Color get outlineVariant => ThemeColors._outlineVariantDark;
}
