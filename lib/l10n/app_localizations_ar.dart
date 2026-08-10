// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نور القلوب';

  @override
  String get tabAdhkar => 'الأذكار';

  @override
  String get tabDuas => 'الأدعية';

  @override
  String get tabPrayer => 'الصلاة';

  @override
  String get tabQuran => 'القرآن';

  @override
  String get titleAdhkar => 'الأذكار';

  @override
  String get titleDuas => 'الأدعية المأثورة';

  @override
  String get titlePrayer => 'مواقيت الصلاة';

  @override
  String get titleQuran => 'القرآن الكريم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get showTasbeeh => 'إظهار المسبحة';

  @override
  String get hideTasbeeh => 'إخفاء المسبحة';

  @override
  String get adhkarMorning => 'أذكار الصباح';

  @override
  String get adhkarEvening => 'أذكار المساء';

  @override
  String get listenReciter => 'استماع لتلاوة القارئ';

  @override
  String get listenReciterSubtitle =>
      'بث مباشر لتلاوة تجريبية للتأكّد من عمل المشغّل';

  @override
  String get tapToCount => 'اضغط للعدّ';

  @override
  String get meaning => 'المعنى';

  @override
  String get prayerAlertsTitle => 'تفعيل التنبيهات الصوتية للصلاة';

  @override
  String get prayerAlertsSubtitle => 'يذكّرك بموعد كل صلاة يومياً';

  @override
  String get playAdhan => 'تشغيل الأذان';

  @override
  String get stop => 'إيقاف';

  @override
  String get alertsOn => 'تم تفعيل تنبيهات الصلاة';

  @override
  String get alertsOff => 'تم إيقاف تنبيهات الصلاة';

  @override
  String get playingAdhan => 'جارٍ تشغيل الأذان';

  @override
  String get adhanError => 'تعذّر تشغيل الأذان (تحقّق من الاتصال بالإنترنت)';

  @override
  String get audioError => 'تعذّر تشغيل الصوت (تحقّق من الاتصال بالإنترنت)';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String prayerNotifTitle(String name) {
    return 'حان الآن موعد $name';
  }

  @override
  String get prayerNotifBody => 'الله أكبر، حيّ على الصلاة';

  @override
  String get quranSearchHint => 'ابحث في الآيات والتفسير…';

  @override
  String get chooseSurah => 'اختر السورة';

  @override
  String get tafsir => 'التفسير';

  @override
  String get memorize => 'الحفظ';

  @override
  String get hideAmount => 'مقدار الإخفاء';

  @override
  String get memorizeHint =>
      'اقرأ الجزء الظاهر ثم اضغط على الآية لكشفها كاملة للتسميع.';

  @override
  String get tapToReveal => 'اضغط للكشف الكامل';

  @override
  String get tafsirLabel => 'التفسير الميسّر';

  @override
  String get noResults => 'لا توجد نتائج مطابقة.';

  @override
  String get surahWord => 'سورة';

  @override
  String get ayahWord => 'الآية';

  @override
  String searchResultSubtitle(String surah, int ayah) {
    return 'سورة $surah — الآية $ayah';
  }

  @override
  String get quranLoadError =>
      'تعذّر تحميل قاعدة بيانات القرآن. يرجى إعادة تشغيل التطبيق.';
}
