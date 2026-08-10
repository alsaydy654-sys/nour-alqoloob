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
}
