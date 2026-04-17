import 'package:fis_app_flutter/core/theme/extension.dart';
import 'package:flutter/material.dart';

/// for consistent typography; style is taken from [BuildContext] theme.
final class ThemeTypography extends Text {
  const ThemeTypography(
    super.data, {
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.maxLines,
    super.textWidthBasis,
    super.textHeightBehavior,
  }) : super();

  /// Display Large
  /// fontSize: 57
  /// fontWeight: FontWeight.w400
  /// letterSpacing: -0.25
  ThemeTypography.h1(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w400,
                    fontSize: (context.textTheme.displayLarge?.fontSize ?? 57) *
                        _getScale(context),
                  ),
        );

  /// Headline Large
  /// fontSize: 32
  /// fontWeight: FontWeight.w400
  /// letterSpacing: 0.0
  ThemeTypography.h2(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w400,
                    fontSize:
                        (context.textTheme.headlineLarge?.fontSize ?? 32) *
                            _getScale(context),
                  ),
        );

  /// Headline Medium
  /// fontSize: 28
  /// fontWeight: FontWeight.w400
  /// letterSpacing: 0.0
  ThemeTypography.h3(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w400,
                    fontSize:
                        (context.textTheme.headlineMedium?.fontSize ?? 28) *
                            _getScale(context),
                  ),
        );

  /// Headline Small
  /// fontSize: 24
  /// fontWeight: FontWeight.w400
  /// letterSpacing: 0.0
  ThemeTypography.h4(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w400,
                    fontSize:
                        (context.textTheme.headlineSmall?.fontSize ?? 24) *
                            _getScale(context),
                  ),
        );

  /// Title Large
  /// fontSize: 22
  /// fontWeight: FontWeight.w500
  /// letterSpacing: 0.0
  ThemeTypography.titleLarge(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w500,
                    fontSize: (context.textTheme.titleLarge?.fontSize ?? 22) *
                        _getScale(context),
                  ),
        );

  /// Title Medium
  /// fontSize: 16
  /// fontWeight: FontWeight.w500
  /// letterSpacing: 0.15
  ThemeTypography.titleMedium(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w500,
                    fontSize: (context.textTheme.titleMedium?.fontSize ?? 16) *
                        _getScale(context),
                  ),
        );

  /// Title Small
  /// fontSize: 14
  /// fontWeight: FontWeight.w500
  /// letterSpacing: 0.1
  ThemeTypography.titleSmall(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w500,
                    fontSize: (context.textTheme.titleSmall?.fontSize ?? 14) *
                        _getScale(context),
                  ),
        );

  /// Body Large
  /// fontSize: 16
  /// fontWeight: FontWeight.w400
  /// letterSpacing: 0.5
  ThemeTypography.bodyLarge(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w400,
                    fontSize: (context.textTheme.bodyLarge?.fontSize ?? 16) *
                        _getScale(context),
                  ),
        );

  /// Body Medium
  /// fontSize: 14
  /// fontWeight: FontWeight.w400
  /// letterSpacing: 0.25
  ThemeTypography.bodyMedium(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w400,
                    fontSize: (context.textTheme.bodyMedium?.fontSize ?? 14) *
                        _getScale(context),
                  ),
        );

  /// Body Small
  /// fontSize: 12
  /// fontWeight: FontWeight.w400
  /// letterSpacing: 0.4
  ThemeTypography.bodySmall(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w400,
                    fontSize: (context.textTheme.bodySmall?.fontSize ?? 12) *
                        _getScale(context),
                  ),
        );

  /// Label Large
  /// fontSize: 14
  /// fontWeight: FontWeight.w500
  /// letterSpacing: 0.1
  ThemeTypography.labelLarge(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w500,
                    fontSize: (context.textTheme.labelLarge?.fontSize ?? 14) *
                        _getScale(context),
                  ),
        );

  /// Label Medium
  /// fontSize: 12
  /// fontWeight: FontWeight.w500
  /// letterSpacing: 0.1
  ThemeTypography.labelMedium(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w500,
                    fontSize: (context.textTheme.labelMedium?.fontSize ?? 12) *
                        _getScale(context),
                  ),
        );

  /// Label Small
  /// fontSize: 11
  /// fontWeight: FontWeight.w500
  /// letterSpacing: 0.1
  ThemeTypography.labelSmall(
    BuildContext context,
    super.data, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    TextStyle? style,
    Color? color,
    FontWeight? weight,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                    fontWeight: weight ?? FontWeight.w500,
                    fontSize: (context.textTheme.labelSmall?.fontSize ?? 11) *
                        _getScale(context),
                  ),
        );

  static double _getScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 340) return 0.85;
    if (width < 400) return 1;
    if (width < 480) return 1.12;
    return 1.25;
  }
}
