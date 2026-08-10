import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('ur'),
  ];

  /// Application title
  ///
  /// In ar, this message translates to:
  /// **'نور القلوب'**
  String get appTitle;

  /// No description provided for @tabAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get tabAdhkar;

  /// No description provided for @tabDuas.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية'**
  String get tabDuas;

  /// No description provided for @tabPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة'**
  String get tabPrayer;

  /// No description provided for @tabQuran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن'**
  String get tabQuran;

  /// No description provided for @titleAdhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get titleAdhkar;

  /// No description provided for @titleDuas.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية المأثورة'**
  String get titleDuas;

  /// No description provided for @titlePrayer.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get titlePrayer;

  /// No description provided for @titleQuran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get titleQuran;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In ar, this message translates to:
  /// **'لغة الجهاز'**
  String get languageSystem;

  /// No description provided for @showTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'إظهار المسبحة'**
  String get showTasbeeh;

  /// No description provided for @hideTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء المسبحة'**
  String get hideTasbeeh;

  /// No description provided for @adhkarMorning.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get adhkarMorning;

  /// No description provided for @adhkarEvening.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get adhkarEvening;

  /// No description provided for @listenReciter.
  ///
  /// In ar, this message translates to:
  /// **'استماع لتلاوة القارئ'**
  String get listenReciter;

  /// No description provided for @listenReciterSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بث مباشر لتلاوة تجريبية للتأكّد من عمل المشغّل'**
  String get listenReciterSubtitle;

  /// No description provided for @tapToCount.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للعدّ'**
  String get tapToCount;

  /// No description provided for @meaning.
  ///
  /// In ar, this message translates to:
  /// **'المعنى'**
  String get meaning;

  /// No description provided for @prayerAlertsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التنبيهات الصوتية للصلاة'**
  String get prayerAlertsTitle;

  /// No description provided for @prayerAlertsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يذكّرك بموعد كل صلاة يومياً'**
  String get prayerAlertsSubtitle;

  /// No description provided for @playAdhan.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الأذان'**
  String get playAdhan;

  /// No description provided for @stop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get stop;

  /// No description provided for @alertsOn.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل تنبيهات الصلاة'**
  String get alertsOn;

  /// No description provided for @alertsOff.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف تنبيهات الصلاة'**
  String get alertsOff;

  /// No description provided for @playingAdhan.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تشغيل الأذان'**
  String get playingAdhan;

  /// No description provided for @adhanError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل الأذان (تحقّق من الاتصال بالإنترنت)'**
  String get adhanError;

  /// No description provided for @audioError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل الصوت (تحقّق من الاتصال بالإنترنت)'**
  String get audioError;

  /// No description provided for @prayerFajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get prayerIsha;

  /// No description provided for @prayerNotifTitle.
  ///
  /// In ar, this message translates to:
  /// **'حان الآن موعد {name}'**
  String prayerNotifTitle(String name);

  /// No description provided for @prayerNotifBody.
  ///
  /// In ar, this message translates to:
  /// **'الله أكبر، حيّ على الصلاة'**
  String get prayerNotifBody;

  /// No description provided for @quranSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الآيات والتفسير…'**
  String get quranSearchHint;

  /// No description provided for @chooseSurah.
  ///
  /// In ar, this message translates to:
  /// **'اختر السورة'**
  String get chooseSurah;

  /// No description provided for @tafsir.
  ///
  /// In ar, this message translates to:
  /// **'التفسير'**
  String get tafsir;

  /// No description provided for @memorize.
  ///
  /// In ar, this message translates to:
  /// **'الحفظ'**
  String get memorize;

  /// No description provided for @hideAmount.
  ///
  /// In ar, this message translates to:
  /// **'مقدار الإخفاء'**
  String get hideAmount;

  /// No description provided for @memorizeHint.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ الجزء الظاهر ثم اضغط على الآية لكشفها كاملة للتسميع.'**
  String get memorizeHint;

  /// No description provided for @tapToReveal.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للكشف الكامل'**
  String get tapToReveal;

  /// No description provided for @tafsirLabel.
  ///
  /// In ar, this message translates to:
  /// **'التفسير الميسّر'**
  String get tafsirLabel;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة.'**
  String get noResults;

  /// No description provided for @surahWord.
  ///
  /// In ar, this message translates to:
  /// **'سورة'**
  String get surahWord;

  /// No description provided for @ayahWord.
  ///
  /// In ar, this message translates to:
  /// **'الآية'**
  String get ayahWord;

  /// No description provided for @searchResultSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سورة {surah} — الآية {ayah}'**
  String searchResultSubtitle(String surah, int ayah);

  /// No description provided for @quranLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل قاعدة بيانات القرآن. يرجى إعادة تشغيل التطبيق.'**
  String get quranLoadError;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'السمة'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get themeDark;

  /// No description provided for @fontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get fontSize;

  /// No description provided for @fontSizePreview.
  ///
  /// In ar, this message translates to:
  /// **'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'**
  String get fontSizePreview;

  /// No description provided for @reciter.
  ///
  /// In ar, this message translates to:
  /// **'المقرئ المفضل'**
  String get reciter;

  /// No description provided for @prayerSection.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة والتنبيهات'**
  String get prayerSection;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @useGps.
  ///
  /// In ar, this message translates to:
  /// **'حساب المواقيت حسب موقعي (GPS)'**
  String get useGps;

  /// No description provided for @locating.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد الموقع…'**
  String get locating;

  /// No description provided for @locationDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع؛ يتم استخدام مواقيت مكة المكرمة'**
  String get locationDenied;

  /// No description provided for @locationCoords.
  ///
  /// In ar, this message translates to:
  /// **'خط العرض {lat} — خط الطول {lng}'**
  String locationCoords(String lat, String lng);

  /// No description provided for @defaultLocationNotice.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت افتراضية (مكة المكرمة)'**
  String get defaultLocationNotice;

  /// No description provided for @refreshLocation.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع'**
  String get refreshLocation;

  /// No description provided for @nextPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة: {name}'**
  String nextPrayer(String name);

  /// No description provided for @prayerSunrise.
  ///
  /// In ar, this message translates to:
  /// **'الشروق'**
  String get prayerSunrise;

  /// No description provided for @remindersTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الأذكار الدورية'**
  String get remindersTitle;

  /// No description provided for @remindersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استغفار وتسبيح وصلاة على النبي تعمل في الخلفية'**
  String get remindersSubtitle;

  /// No description provided for @reminderInterval.
  ///
  /// In ar, this message translates to:
  /// **'التكرار'**
  String get reminderInterval;

  /// No description provided for @everyNHours.
  ///
  /// In ar, this message translates to:
  /// **'كل {hours} ساعة'**
  String everyNHours(int hours);

  /// No description provided for @reminderTitleIstighfar.
  ///
  /// In ar, this message translates to:
  /// **'وقت الاستغفار'**
  String get reminderTitleIstighfar;

  /// No description provided for @reminderBodyIstighfar.
  ///
  /// In ar, this message translates to:
  /// **'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ'**
  String get reminderBodyIstighfar;

  /// No description provided for @reminderTitleTasbih.
  ///
  /// In ar, this message translates to:
  /// **'وقت التسبيح'**
  String get reminderTitleTasbih;

  /// No description provided for @reminderBodyTasbih.
  ///
  /// In ar, this message translates to:
  /// **'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'**
  String get reminderBodyTasbih;

  /// No description provided for @reminderTitleSalat.
  ///
  /// In ar, this message translates to:
  /// **'وقت الصلاة على النبي'**
  String get reminderTitleSalat;

  /// No description provided for @reminderBodySalat.
  ///
  /// In ar, this message translates to:
  /// **'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ'**
  String get reminderBodySalat;

  /// No description provided for @remindersOn.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل تنبيهات الأذكار الدورية'**
  String get remindersOn;

  /// No description provided for @remindersOff.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف تنبيهات الأذكار الدورية'**
  String get remindersOff;

  /// No description provided for @tasbeehSection.
  ///
  /// In ar, this message translates to:
  /// **'المسبحة'**
  String get tasbeehSection;

  /// No description provided for @overlayTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'المسبحة فوق التطبيقات'**
  String get overlayTasbeeh;

  /// No description provided for @overlaySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تظهر فوق أي تطبيق آخر مع العدّاد'**
  String get overlaySubtitle;

  /// No description provided for @overlayEnable.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل المسبحة العائمة'**
  String get overlayEnable;

  /// No description provided for @overlayDisable.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف المسبحة العائمة'**
  String get overlayDisable;

  /// No description provided for @overlayPermissionNeeded.
  ///
  /// In ar, this message translates to:
  /// **'يجب السماح بـ«العرض فوق التطبيقات الأخرى»'**
  String get overlayPermissionNeeded;

  /// No description provided for @overlayUnsupported.
  ///
  /// In ar, this message translates to:
  /// **'متوفّرة على أندرويد فقط'**
  String get overlayUnsupported;

  /// No description provided for @vibrateOnTap.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز خفيف عند النقر'**
  String get vibrateOnTap;

  /// No description provided for @resetCounter.
  ///
  /// In ar, this message translates to:
  /// **'تصفير العدّاد'**
  String get resetCounter;

  /// No description provided for @counterReset.
  ///
  /// In ar, this message translates to:
  /// **'تم تصفير العدّاد'**
  String get counterReset;

  /// No description provided for @notificationsUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات غير مدعومة على هذه المنصّة'**
  String get notificationsUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
