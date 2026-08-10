import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// اللغات المدعومة في التطبيق (ترتيبها ترتيب العرض في الإعدادات).
const List<Locale> kSupportedLocales = [
  Locale('ar'),
  Locale('en'),
  Locale('fr'),
  Locale('ur'),
];

/// يتحكّم في اللغة المختارة يدوياً ويحفظها؛ عند null يتبع لغة الجهاز.
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const _prefsKey = 'app_locale';

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
  }

  /// تعيين اللغة يدوياً؛ تمرير null يُعيد اتباع لغة الجهاز.
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
