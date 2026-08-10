// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'نورِ قلوب';

  @override
  String get tabAdhkar => 'اذکار';

  @override
  String get tabDuas => 'دعائیں';

  @override
  String get tabPrayer => 'نماز';

  @override
  String get tabQuran => 'قرآن';

  @override
  String get titleAdhkar => 'اذکار';

  @override
  String get titleDuas => 'ماثور دعائیں';

  @override
  String get titlePrayer => 'نماز کے اوقات';

  @override
  String get titleQuran => 'قرآن کریم';

  @override
  String get settings => 'ترتیبات';

  @override
  String get language => 'زبان';

  @override
  String get languageSystem => 'آلے کی زبان';

  @override
  String get showTasbeeh => 'تسبیح دکھائیں';

  @override
  String get hideTasbeeh => 'تسبیح چھپائیں';

  @override
  String get adhkarMorning => 'صبح کے اذکار';

  @override
  String get adhkarEvening => 'شام کے اذکار';

  @override
  String get listenReciter => 'قاری کی تلاوت سنیں';

  @override
  String get listenReciterSubtitle =>
      'پلیئر کی جانچ کے لیے نمونہ تلاوت کی لائیو سٹریمنگ';

  @override
  String get tapToCount => 'گننے کے لیے دبائیں';

  @override
  String get meaning => 'مفہوم';

  @override
  String get prayerAlertsTitle => 'نماز کی صوتی اطلاعات فعال کریں';

  @override
  String get prayerAlertsSubtitle => 'ہر نماز کی روزانہ یاد دہانی';

  @override
  String get playAdhan => 'اذان چلائیں';

  @override
  String get stop => 'روکیں';

  @override
  String get alertsOn => 'نماز کی اطلاعات فعال ہو گئیں';

  @override
  String get alertsOff => 'نماز کی اطلاعات بند ہو گئیں';

  @override
  String get playingAdhan => 'اذان چل رہی ہے';

  @override
  String get adhanError => 'اذان نہیں چل سکی (اپنا انٹرنیٹ کنکشن چیک کریں)';

  @override
  String get audioError => 'آواز نہیں چل سکی (اپنا انٹرنیٹ کنکشن چیک کریں)';

  @override
  String get prayerFajr => 'فجر';

  @override
  String get prayerDhuhr => 'ظہر';

  @override
  String get prayerAsr => 'عصر';

  @override
  String get prayerMaghrib => 'مغرب';

  @override
  String get prayerIsha => 'عشاء';

  @override
  String prayerNotifTitle(String name) {
    return 'اب $name کا وقت ہو گیا ہے';
  }

  @override
  String get prayerNotifBody => 'اللہ اکبر، نماز کی طرف آؤ';

  @override
  String get quranSearchHint => 'آیات اور تفسیر میں تلاش کریں…';

  @override
  String get chooseSurah => 'سورہ منتخب کریں';

  @override
  String get tafsir => 'تفسیر';

  @override
  String get memorize => 'حفظ';

  @override
  String get hideAmount => 'چھپانے کی مقدار';

  @override
  String get memorizeHint =>
      'ظاہر حصہ پڑھیں، پھر آیت کو مکمل ظاہر کرنے کے لیے اس پر دبائیں۔';

  @override
  String get tapToReveal => 'مکمل ظاہر کرنے کے لیے دبائیں';

  @override
  String get tafsirLabel => 'تفسیر المیسر';

  @override
  String get noResults => 'کوئی مماثل نتیجہ نہیں۔';

  @override
  String get surahWord => 'سورہ';

  @override
  String get ayahWord => 'آیت';

  @override
  String searchResultSubtitle(String surah, int ayah) {
    return 'سورہ $surah — آیت $ayah';
  }

  @override
  String get quranLoadError =>
      'قرآن ڈیٹا بیس لوڈ نہیں ہو سکا۔ براہِ کرم ایپ دوبارہ شروع کریں۔';

  @override
  String get appearance => 'ظاہری شکل';

  @override
  String get theme => 'تھیم';

  @override
  String get themeSystem => 'نظام کے مطابق';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'نائٹ موڈ';

  @override
  String get fontSize => 'فونٹ کا سائز';

  @override
  String get fontSizePreview => 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';

  @override
  String get reciter => 'پسندیدہ قاری';

  @override
  String get prayerSection => 'نماز اور اطلاعات';

  @override
  String get location => 'مقام';

  @override
  String get useGps => 'میرے مقام (GPS) کے مطابق اوقات';

  @override
  String get locating => 'مقام کا تعین ہو رہا ہے…';

  @override
  String get locationDenied =>
      'مقام کی اجازت رد ہوئی؛ مکہ مکرمہ کے اوقات استعمال ہو رہے ہیں';

  @override
  String locationCoords(String lat, String lng) {
    return 'عرض البلد $lat — طول البلد $lng';
  }

  @override
  String get defaultLocationNotice => 'طے شدہ اوقات (مکہ مکرمہ)';

  @override
  String get refreshLocation => 'مقام تازہ کریں';

  @override
  String nextPrayer(String name) {
    return 'اگلی نماز: $name';
  }

  @override
  String get prayerSunrise => 'طلوعِ آفتاب';

  @override
  String get remindersTitle => 'اذکار کی وقفے وقفے سے یاد دہانی';

  @override
  String get remindersSubtitle => 'استغفار، تسبیح اور درود پس منظر میں';

  @override
  String get reminderInterval => 'تکرار';

  @override
  String everyNHours(int hours) {
    return 'ہر $hours گھنٹے';
  }

  @override
  String get reminderTitleIstighfar => 'استغفار کا وقت';

  @override
  String get reminderBodyIstighfar => 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ';

  @override
  String get reminderTitleTasbih => 'تسبیح کا وقت';

  @override
  String get reminderBodyTasbih => 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ';

  @override
  String get reminderTitleSalat => 'درود شریف کا وقت';

  @override
  String get reminderBodySalat =>
      'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ';

  @override
  String get remindersOn => 'اذکار کی یاد دہانی فعال ہو گئی';

  @override
  String get remindersOff => 'اذکار کی یاد دہانی بند ہو گئی';

  @override
  String get tasbeehSection => 'تسبیح';

  @override
  String get overlayTasbeeh => 'دوسری ایپس کے اوپر تسبیح';

  @override
  String get overlaySubtitle => 'کاؤنٹر کے ساتھ کسی بھی ایپ کے اوپر نظر آتی ہے';

  @override
  String get overlayEnable => 'فلوٹنگ تسبیح چلائیں';

  @override
  String get overlayDisable => 'فلوٹنگ تسبیح بند کریں';

  @override
  String get overlayPermissionNeeded =>
      'براہِ کرم «دوسری ایپس کے اوپر دکھانے» کی اجازت دیں';

  @override
  String get overlayUnsupported => 'صرف اینڈرائیڈ پر دستیاب';

  @override
  String get vibrateOnTap => 'دبانے پر ہلکی وائبریشن';

  @override
  String get resetCounter => 'کاؤنٹر صفر کریں';

  @override
  String get counterReset => 'کاؤنٹر صفر کر دیا گیا';

  @override
  String get notificationsUnavailable => 'اس پلیٹ فارم پر اطلاعات معاون نہیں';
}
