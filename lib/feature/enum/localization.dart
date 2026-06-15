import 'package:fis_app_flutter/app/import/app.dart';

enum EnumLocalization {
  tr('Türkçe', '🇹🇷', AppLocale.tr),
  en('English', '🇬🇧',AppLocale.en);

  const EnumLocalization(this.icon, this.label, this.locale);
  final String icon;
  final String label;
  final AppLocale  locale;
}
