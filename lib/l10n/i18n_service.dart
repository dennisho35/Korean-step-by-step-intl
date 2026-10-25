import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';

class I18nService {
  static const List<String> supportedLocales = [
    'en-GB', 'th-TH', 'ja-JP', 'vi-VN', 'fr-FR',
    'de-DE', 'es-ES', 'ru-RU', 'uk-UA', 'it-IT', 'zh-TW'
  ];

  Map<String, dynamic> _localesMeta = {};
  Map<String, dynamic> _uiStrings = {};
  String _currentLocale = 'en-GB';

  String get currentLocale => _currentLocale;
  Map<String, dynamic> get localesMeta => _localesMeta;

  Future<void> loadTranslations({String? savedLocale}) async {
    final raw = await rootBundle.loadString('assets/data/app_translations.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    _localesMeta = data['locales'] as Map<String, dynamic>;
    _uiStrings = data['uiStrings'] as Map<String, dynamic>;

    if (savedLocale != null && supportedLocales.contains(savedLocale)) {
      _currentLocale = savedLocale;
    } else {
      final sysLoc = PlatformDispatcher.instance.locale;
      final tag = '${sysLoc.languageCode}-${sysLoc.countryCode ?? ''}';
      final match = supportedLocales.firstWhere(
        (l) => l.toLowerCase() == tag.toLowerCase() || l.split('-').first == sysLoc.languageCode,
        orElse: () => 'en-GB',
      );
      _currentLocale = match;
    }
  }

  void setLocale(String localeCode) {
    if (supportedLocales.contains(localeCode)) {
      _currentLocale = localeCode;
    } else {
      _currentLocale = 'en-GB';
    }
  }

  String t(String key) {
    final langMap = _uiStrings[_currentLocale] as Map<String, dynamic>?;
    if (langMap != null && langMap[key] != null) {
      return langMap[key].toString();
    }
    final fallbackMap = _uiStrings['en-GB'] as Map<String, dynamic>?;
    return fallbackMap?[key]?.toString() ?? key;
  }

  String approxDisclaimer() {
    final meta = _localesMeta[_currentLocale] as Map<String, dynamic>?;
    return meta?['approxDisclaimer']?.toString() ?? '';
  }

  String pickLocalized(Map<String, dynamic>? map, String fallback) {
    if (map == null) return fallback;
    return map[_currentLocale]?.toString() ??
           map['en-GB']?.toString() ??
           fallback;
  }
}
