///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$page$en page = Translations$page$en._(_root);
}

// Path: page
class Translations$page$en {
	Translations$page$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$page$login$en login = Translations$page$login$en._(_root);
}

// Path: page.login
class Translations$page$login$en {
	Translations$page$login$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Username'
	String get textfield_username => 'Username';

	/// en: 'Password'
	String get textfield_password => 'Password';

	/// en: 'Login'
	String get button_login => 'Login';

	/// en: 'Register'
	String get button_register => 'Register';

	/// en: 'Forgot Password'
	String get button_forget_password => 'Forgot Password';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'page.login.textfield_username' => 'Username',
			'page.login.textfield_password' => 'Password',
			'page.login.button_login' => 'Login',
			'page.login.button_register' => 'Register',
			'page.login.button_forget_password' => 'Forgot Password',
			_ => null,
		};
	}
}
