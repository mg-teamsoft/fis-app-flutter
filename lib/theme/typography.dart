import 'package:fis_app_flutter/theme/extension.dart';
import 'package:flutter/material.dart';

/// Theme-backed text widget. Use named constructors (e.g. [ProductText.h1])
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
    Color? color,
  }) : super(
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: color ?? context.colorScheme.onPrimary,
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
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: context.colorScheme.onPrimary,
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
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
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
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
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
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
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
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
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
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
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
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
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
    Color? color,
  }) : super(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? context.colorScheme.onPrimary,
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
    Color? color,
  }) : super(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color ?? context.colorScheme.onPrimary,
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
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                  ),
        );

  ThemeTypography.labelMedium(
    BuildContext context,
    super.data, {
    super.key,
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                  ),
        );

  ThemeTypography.labelSmall(
    BuildContext context,
    super.data, {
    super.key,
    TextStyle? style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    Color? color,
  }) : super(
          style: style ??
              Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color ?? context.colorScheme.onPrimary,
                  ),
        );
}
