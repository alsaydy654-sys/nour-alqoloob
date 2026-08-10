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

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'الوضع الليلي';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String get fontSizePreview => 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';

  @override
  String get reciter => 'المقرئ المفضل';

  @override
  String get prayerSection => 'الصلاة والتنبيهات';

  @override
  String get location => 'الموقع';

  @override
  String get useGps => 'حساب المواقيت حسب موقعي (GPS)';

  @override
  String get locating => 'جارٍ تحديد الموقع…';

  @override
  String get locationDenied =>
      'تم رفض إذن الموقع؛ يتم استخدام مواقيت مكة المكرمة';

  @override
  String locationCoords(String lat, String lng) {
    return 'خط العرض $lat — خط الطول $lng';
  }

  @override
  String get defaultLocationNotice => 'مواقيت افتراضية (مكة المكرمة)';

  @override
  String get refreshLocation => 'تحديث الموقع';

  @override
  String nextPrayer(String name) {
    return 'الصلاة القادمة: $name';
  }

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get remindersTitle => 'تنبيهات الأذكار الدورية';

  @override
  String get remindersSubtitle =>
      'استغفار وتسبيح وصلاة على النبي تعمل في الخلفية';

  @override
  String get reminderInterval => 'التكرار';

  @override
  String everyNHours(int hours) {
    return 'كل $hours ساعة';
  }

  @override
  String get reminderTitleIstighfar => 'وقت الاستغفار';

  @override
  String get reminderBodyIstighfar => 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ';

  @override
  String get reminderTitleTasbih => 'وقت التسبيح';

  @override
  String get reminderBodyTasbih => 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ';

  @override
  String get reminderTitleSalat => 'وقت الصلاة على النبي';

  @override
  String get reminderBodySalat =>
      'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ';

  @override
  String get remindersOn => 'تم تفعيل تنبيهات الأذكار الدورية';

  @override
  String get remindersOff => 'تم إيقاف تنبيهات الأذكار الدورية';

  @override
  String get tasbeehSection => 'المسبحة';

  @override
  String get overlayTasbeeh => 'المسبحة فوق التطبيقات';

  @override
  String get overlaySubtitle => 'تظهر فوق أي تطبيق آخر مع العدّاد';

  @override
  String get overlayEnable => 'تشغيل المسبحة العائمة';

  @override
  String get overlayDisable => 'إيقاف المسبحة العائمة';

  @override
  String get overlayPermissionNeeded =>
      'يجب السماح بـ«العرض فوق التطبيقات الأخرى»';

  @override
  String get overlayUnsupported => 'متوفّرة على أندرويد فقط';

  @override
  String get vibrateOnTap => 'اهتزاز خفيف عند النقر';

  @override
  String get resetCounter => 'تصفير العدّاد';

  @override
  String get counterReset => 'تم تصفير العدّاد';

  @override
  String get notificationsUnavailable => 'التنبيهات غير مدعومة على هذه المنصّة';
}
