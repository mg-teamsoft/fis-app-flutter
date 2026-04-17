import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final class AppLocalization {
  static final Iterable<LocalizationsDelegate<dynamic>> _delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static final List<Locale> _supportedLocales = [
    const Locale('en'),
    const Locale('tr'),
    const Locale('tr', 'TR'),
  ];

  // GET Function
  Iterable<LocalizationsDelegate<dynamic>> get delegate => _delegates;
  List<Locale> get supportLocales => _supportedLocales;
}
