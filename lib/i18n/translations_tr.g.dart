///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsTr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsTr _root = this; // ignore: unused_field

	@override 
	TranslationsTr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTr(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$page$tr page = _Translations$page$tr._(_root);
}

// Path: page
class _Translations$page$tr implements Translations$page$en {
	_Translations$page$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override late final _Translations$page$login$tr login = _Translations$page$login$tr._(_root);
}

// Path: page.login
class _Translations$page$login$tr implements Translations$page$login$en {
	_Translations$page$login$tr._(this._root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get textfield_username => 'Kullanıcı Adınız';
	@override String get textfield_password => 'Şifreniz';
	@override String get button_login => 'Giriş Yap';
	@override String get button_register => 'Kayıt Ol';
	@override String get button_forget_password => 'Şifremi Unuttum';
}

/// The flat map containing all translations for locale <tr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'page.login.textfield_username' => 'Kullanıcı Adınız',
			'page.login.textfield_password' => 'Şifreniz',
			'page.login.button_login' => 'Giriş Yap',
			'page.login.button_register' => 'Kayıt Ol',
			'page.login.button_forget_password' => 'Şifremi Unuttum',
			_ => null,
		};
	}
}
