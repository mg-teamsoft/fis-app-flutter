import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class CoreDate {
  CoreDate._();

  /// Date Control is not future date and returns formatted date string based on locale.
  static String dateController({
    required DateTime date,
    required Locale locale,
  }) =>
      _Date.dateController(date: date, locale: locale);

  /// return bool value if date is not future.
  static bool isNotFuture(DateTime date) => _Date.isNotFuture(date);

  /// return bool value if date is not past.
  static bool isNotPast(DateTime date) => _Date.isNotPast(date);

  /// return formatted date string based on Turkish locale.
  static String formatTR(DateTime date) => _Date.formatTR(date);

  /// return formatted date string based on United Kingdom (England) locale.
  static String formatUK(DateTime date) => _Date.formatUK(date);

  /// return formatted date string based on United States locale.
  static String formatUS(DateTime date) => _Date.formatUS(date);

  /// 24-Hour Format (Technical/System-Level Usage)
  static String formatSystemClock(DateTime date) => _Date.formatUS24Hour(date);
}

class _Date {
  _Date._();

  static final DateFormat _formatTR =
      DateFormat('dd.MM.yyyy HH:mm:ss.SSS', 'tr_TR');
  static final DateFormat _formatUK =
      DateFormat('dd/MM/yyyy HH:mm:ss.SSS', 'en_GB');
  static final DateFormat _formatUS =
      DateFormat('MM/dd/yyyy hh:mm:ss.SSS a', 'en_US');
  static final DateFormat _us24HourFormat =
      DateFormat('MM/dd/yyyy HH:mm:ss.SSS', 'en_US');

  static String formatTR(DateTime date) {
    return _formatTR.format(date);
  }

  static String formatUK(DateTime date) {
    return _formatUK.format(date);
  }

  static String formatUS(DateTime date) {
    return _formatUS.format(date);
  }

  static String formatUS24Hour(DateTime date) {
    return _us24HourFormat.format(date);
  }

  static bool isNotFuture(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static bool isNotPast(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static String dateLocaleFormat({
    required DateTime date,
    required Locale locale,
  }) {
    if (locale.languageCode == 'tr') {
      return _formatTR.format(date);
    } else if (locale.languageCode == 'en') {
      if (locale.countryCode == 'US') {
        return _formatUS.format(date);
      } else if (locale.countryCode == 'GB') {
        return _formatUK.format(date);
      } else {
        throw ArgumentError(
          'Unsupported English locale: ${locale.countryCode}',
        );
      }
    } else {
      throw ArgumentError('Unsupported locale: ${locale.languageCode}');
    }
  }

  static String dateController({
    required DateTime date,
    required Locale locale,
    bool isNotPast = false,
    bool isNotFuture = false,
  }) {
    final now = DateTime.now();
    if (isNotFuture) {
      if (date.isAfter(now)) {
        throw ArgumentError(
          'The date cannot be in the future.',
        );
      }
    } else if (isNotPast) {
      if (date.isBefore(now)) {
        throw ArgumentError(
          'The date cannot be in the past.',
        );
      }
    }
    return dateLocaleFormat(date: date, locale: locale);
  }
}
