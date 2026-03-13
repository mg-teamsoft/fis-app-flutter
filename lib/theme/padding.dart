import 'package:flutter/material.dart';

final class ThemePadding extends EdgeInsets {
  static const double _spacingXs = 8;
  static const double _spacingS = 10;
  static const double _spacingM = 16;
  static const double _spacingL = 20;
  static const double _spacingXl = 24;
  static const double _spacingXXl = 32;

  /// [10] padding all
  const ThemePadding.all10() : super.all(_spacingS);

  /// [15] padding all
  const ThemePadding.all15() : super.all(15);

  /// [16] padding all
  const ThemePadding.all16() : super.all(_spacingM);

  /// [20] padding all
  const ThemePadding.all20() : super.all(_spacingL);

  /// [24] padding all
  const ThemePadding.all24() : super.all(_spacingXl);

  /// [32] padding all
  const ThemePadding.all32() : super.all(_spacingXXl);

  /// [20] horizontal symmetric
  const ThemePadding.horizontalSymmetric()
      : super.symmetric(horizontal: _spacingL);

  /// [16] horizontal symmetric
  const ThemePadding.horizontalSymmetricMedium()
      : super.symmetric(horizontal: _spacingM);

  /// [24] horizontal symmetric
  const ThemePadding.horizontalSymmetricLarge()
      : super.symmetric(horizontal: _spacingXl);

  /// [20] vertical symmetric
  const ThemePadding.verticalSymmetric() : super.symmetric(vertical: _spacingL);

  /// [8] vertical symmetric (alias: page vertical 8)
  const ThemePadding.verticalSymmetricSmall()
      : super.symmetric(vertical: _spacingXs);

  /// [8] page vertical (same as verticalSymmetricSmall)
  const ThemePadding.pageVertical8() : super.symmetric(vertical: _spacingXs);

  /// [16] vertical symmetric
  const ThemePadding.verticalSymmetricMedium()
      : super.symmetric(vertical: _spacingM);

  /// [24] vertical symmetric
  const ThemePadding.verticalSymmetricLarge()
      : super.symmetric(vertical: _spacingXl);

  /// [8] margin bottom
  const ThemePadding.marginBottom8() : super.only(bottom: _spacingXs);

  /// [10] margin bottom
  const ThemePadding.marginBottom10() : super.only(bottom: _spacingS);

  /// [12] margin bottom
  const ThemePadding.marginBottom12() : super.only(bottom: 12);

  /// [15] margin bottom
  const ThemePadding.marginBottom15() : super.only(bottom: 15);

  /// [16] margin bottom
  const ThemePadding.marginBottom16() : super.only(bottom: _spacingM);

  /// [20] margin bottom
  const ThemePadding.marginBottom20() : super.only(bottom: _spacingL);

  /// [24] margin bottom
  const ThemePadding.marginBottom24() : super.only(bottom: _spacingXl);

  /// [32] margin bottom
  const ThemePadding.marginBottom32() : super.only(bottom: _spacingXXl);

  /// [8] horizontal symmetric free
  // ignore: prefer_const_constructors_in_immutables
  ThemePadding.horizontalSymmetricFree(double horizontal)
      : super.symmetric(horizontal: horizontal);
  // ignore: prefer_const_constructors_in_immutables -- runtime value
  ThemePadding.verticalSymmetricFree(double vertical)
      : super.symmetric(vertical: vertical);
}
