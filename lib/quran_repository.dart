import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// آية واحدة تحمل النص القرآني والتفسير الميسّر.
class Ayah {
  final int number;
  final String text;
  final String tafsir;
  const Ayah({required this.number, required this.text, required this.tafsir});

  factory Ayah.fromJson(Map<String, dynamic> j) => Ayah(
        number: j['n'] as int,
        text: j['text'] as String,
        tafsir: (j['tafsir'] as String?) ?? '',
      );
}

/// سورة كاملة مع آياتها.
class QuranSurah {
  final int number;
  final String name;
  final String englishName;
  final String type; // Meccan / Medinan
  final List<Ayah> ayahs;

  const QuranSurah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.type,
    required this.ayahs,
  });

  bool get isMeccan => type.toLowerCase() == 'meccan';

  factory QuranSurah.fromJson(Map<String, dynamic> j) => QuranSurah(
        number: j['number'] as int,
        name: j['name'] as String,
        englishName: (j['englishName'] as String?) ?? '',
        type: (j['type'] as String?) ?? '',
        ayahs: (j['ayahs'] as List<dynamic>)
            .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// نتيجة بحث داخل الآيات.
class SearchHit {
  final QuranSurah surah;
  final Ayah ayah;
  const SearchHit(this.surah, this.ayah);
}

/// قاعدة البيانات المحلية للقرآن الكريم والتفسير الميسّر.
///
/// تُحمَّل مرة واحدة من ملف الأصول `assets/quran/quran.json` وتبقى في الذاكرة،
/// وتوفّر قائمة السور والبحث داخل نصوص الآيات والتفسير.
class QuranRepository {
  QuranRepository._();
  static final QuranRepository instance = QuranRepository._();

  List<QuranSurah> _surahs = const [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<QuranSurah> get surahs => _surahs;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/quran/quran.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    _surahs = (data['surahs'] as List<dynamic>)
        .map((e) => QuranSurah.fromJson(e as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }

  /// تطبيع النص العربي للبحث: إزالة التشكيل وتوحيد الهمزات.
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      // تجاهل علامات التشكيل والرموز القرآنية (النطاق 0x0610–0x06DC و0x06DF–0x06ED).
      if ((rune >= 0x0610 && rune <= 0x061A) ||
          (rune >= 0x064B && rune <= 0x065F) ||
          rune == 0x0670 ||
          (rune >= 0x06D6 && rune <= 0x06DC) ||
          (rune >= 0x06DF && rune <= 0x06ED)) {
        continue;
      }
      buffer.write(ch);
    }
    return buffer
        .toString()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ـ', '')
        .trim();
  }

  /// بحث داخل الآيات (والتفسير) يُرجِع حتى [limit] نتيجة.
  List<SearchHit> search(String query, {int limit = 100}) {
    final q = normalize(query);
    if (q.isEmpty) return const [];
    final hits = <SearchHit>[];
    for (final surah in _surahs) {
      for (final ayah in surah.ayahs) {
        if (normalize(ayah.text).contains(q) ||
            normalize(ayah.tafsir).contains(q)) {
          hits.add(SearchHit(surah, ayah));
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }
}
