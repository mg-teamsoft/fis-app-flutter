import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

final class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.bar,
    required this.success,
    required this.selected,
    required this.warning,
    required this.error,
    required this.info,
    required this.cardBackground,
    required this.divider,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color brandPrimary;
  final Color brandSecondary;
  final Color bar;
  final Color success;
  final Color selected;
  final Color warning;
  final Color error;
  final Color info;
  final Color cardBackground;
  final Color divider;
  final Color shimmerBase;
  final Color shimmerHighlight;

  static AppThemeExtension light = AppThemeExtension(
    brandPrimary: ThemeColors.light.primary,
    brandSecondary: ThemeColors.light.secondary,
    bar: const Color(0xffBFC9D1),
    success: const Color(0xff008000),
    selected: const Color(0xff76D2DB),
    warning: const Color(0xFFFFD45A),
    error: const Color(0xFFCF0F0F),
    info: const Color(0xff0052ae),
    cardBackground: ThemeColors.light.surface,
    divider: ThemeColors.light.outline,
    shimmerBase: const Color(0xFFF7F6E5),
    shimmerHighlight: const Color(0xFFF5F5F5),
  );

  static AppThemeExtension dark = AppThemeExtension(
    brandPrimary: ThemeColors.dark.primary,
    brandSecondary: ThemeColors.dark.secondary,
    bar: const Color(0xff000000),
    success: const Color(0xff008000),
    selected: const Color(0xff3A9AFF),
    warning: const Color(0xFFFFB74D),
    info: ThemeColors.dark.secondary,
    error: const Color(0xFFCF0F0F),
    cardBackground: ThemeColors.dark.surfaceContainerHigh,
    divider: ThemeColors.dark.outlineVariant,
    shimmerBase: const Color(0xFF424242),
    shimmerHighlight: const Color(0xFF616161),
  );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? bar,
    Color? success,
    Color? selected,
    Color? warning,
    Color? error,
    Color? info,
    Color? cardBackground,
    Color? divider,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppThemeExtension(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      bar: bar ?? this.bar,
      success: success ?? this.success,
      selected: selected ?? this.selected,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      cardBackground: cardBackground ?? this.cardBackground,
      divider: divider ?? this.divider,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      bar: Color.lerp(bar, other.bar, t)!,
      success: Color.lerp(success, other.success, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      error: Color.lerp(error, other.error, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

extension AppThemeExtensionContext on BuildContext {
  AppThemeExtension get theme => Theme.of(this).extension<AppThemeExtension>()!;
}

extension AppTextThemeContext on BuildContext {
  TextTheme get textTheme => ThemeTextStyle.textTheme;
  ThemeData get themedata => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
