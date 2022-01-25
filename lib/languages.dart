import 'dart:core';

class AppLanguage {
  String displayName;
  String localeCode;
  String languageCode;

  AppLanguage(this.displayName, this.localeCode, this.languageCode);
}

class Languages {
  static final List<AppLanguage> languages = [
    AppLanguage("English", "en", "en-US"),
    AppLanguage("Deutsch", "de", "de-DE"),
    AppLanguage("Français", "fr", "fr-FR"),
    AppLanguage("Italiano", "it", "it-IT"),
    AppLanguage("Русский", "ru", "ru-RU"),
    AppLanguage("Türkçe", "tr", "tr-TR")
  ];

  static List<String> get languageCodes =>
      languages.map((lang) => lang.languageCode).toList();

  static AppLanguage fromLocaleCode(String localeCode) => languages
      .firstWhere((lang) => lang.localeCode == localeCode, orElse: null);
}
