part of '../widget/appbar/appbar.dart';

enum _EnumNotification {
  info,
  warning,
  error,
  success,
  none;

  static _EnumNotification fromName(String? name) {
    return _EnumNotification.values.firstWhere(
      (e) => e.name == name,
      orElse: () => _EnumNotification.none,
    );
  }
}
