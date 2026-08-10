import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// ذِكر مترجَم: النص العربي الثابت + ترجمة المعنى + عدد التكرار.
class LocalizedDhikr {
  final String arabic;
  final String translation;
  final int count;
  const LocalizedDhikr(
      {required this.arabic, required this.translation, required this.count});

  factory LocalizedDhikr.fromJson(Map<String, dynamic> j) => LocalizedDhikr(
        arabic: j['ar'] as String,
        translation: (j['tr'] as String?) ?? '',
        count: (j['count'] as int?) ?? 1,
      );
}

/// دعاء مترجَم: عنوان مترجم + النص العربي الثابت + ترجمة المعنى.
class LocalizedDua {
  final String title;
  final String arabic;
  final String translation;
  const LocalizedDua(
      {required this.title, required this.arabic, required this.translation});

  factory LocalizedDua.fromJson(Map<String, dynamic> j) => LocalizedDua(
        title: j['title'] as String,
        arabic: j['ar'] as String,
        translation: (j['tr'] as String?) ?? '',
      );
}

/// محتوى الأذكار والأدعية للغة واحدة.
class AppContent {
  final List<LocalizedDhikr> morning;
  final List<LocalizedDhikr> evening;
  final List<LocalizedDua> duas;
  const AppContent(
      {required this.morning, required this.evening, required this.duas});
}

/// يُحمّل محتوى الأذكار والأدعية من ملفات JSON للترجمة بحسب رمز اللغة.
///
/// النصوص العربية (نص الذِّكر/الدعاء) ثابتة عبر جميع اللغات لأنها نص العبادة،
/// بينما يتغيّر حقل `tr` (المعنى) والعناوين حسب اللغة المختارة.
class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  /// اللغات التي تتوفّر لها ملفات محتوى؛ يُستخدم غيرها الإنجليزية كاحتياط.
  static const Set<String> supported = {'ar', 'en', 'fr', 'ur'};

  final Map<String, AppContent> _cache = {};

  Future<AppContent> forLanguage(String languageCode) async {
    final lang = supported.contains(languageCode) ? languageCode : 'en';
    final cached = _cache[lang];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/i18n/content_$lang.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    List<LocalizedDhikr> dhikrs(String key) => (data[key] as List<dynamic>)
        .map((e) => LocalizedDhikr.fromJson(e as Map<String, dynamic>))
        .toList();
    final content = AppContent(
      morning: dhikrs('morning'),
      evening: dhikrs('evening'),
      duas: (data['duas'] as List<dynamic>)
          .map((e) => LocalizedDua.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    _cache[lang] = content;
    return content;
  }
}
