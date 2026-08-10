// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nour Al-Qoloob';

  @override
  String get tabAdhkar => 'Adhkar';

  @override
  String get tabDuas => 'Duas';

  @override
  String get tabPrayer => 'Prayer';

  @override
  String get tabQuran => 'Quran';

  @override
  String get titleAdhkar => 'Adhkar';

  @override
  String get titleDuas => 'Prophetic Supplications';

  @override
  String get titlePrayer => 'Prayer Times';

  @override
  String get titleQuran => 'The Holy Quran';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get showTasbeeh => 'Show Tasbeeh';

  @override
  String get hideTasbeeh => 'Hide Tasbeeh';

  @override
  String get adhkarMorning => 'Morning Adhkar';

  @override
  String get adhkarEvening => 'Evening Adhkar';

  @override
  String get listenReciter => 'Listen to a reciter';

  @override
  String get listenReciterSubtitle =>
      'Live streaming sample recitation to verify the player works';

  @override
  String get tapToCount => 'Tap to count';

  @override
  String get meaning => 'Meaning';

  @override
  String get prayerAlertsTitle => 'Enable prayer audio alerts';

  @override
  String get prayerAlertsSubtitle => 'Reminds you of each prayer daily';

  @override
  String get playAdhan => 'Play Adhan';

  @override
  String get stop => 'Stop';

  @override
  String get alertsOn => 'Prayer alerts enabled';

  @override
  String get alertsOff => 'Prayer alerts disabled';

  @override
  String get playingAdhan => 'Playing Adhan';

  @override
  String get adhanError =>
      'Could not play the Adhan (check your internet connection)';

  @override
  String get audioError =>
      'Could not play the audio (check your internet connection)';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String prayerNotifTitle(String name) {
    return 'It is now time for $name';
  }

  @override
  String get prayerNotifBody => 'Allahu Akbar, come to prayer';

  @override
  String get quranSearchHint => 'Search verses and tafsir…';

  @override
  String get chooseSurah => 'Choose surah';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get memorize => 'Memorize';

  @override
  String get hideAmount => 'Hide amount';

  @override
  String get memorizeHint =>
      'Read the visible part, then tap a verse to reveal it fully for recitation.';

  @override
  String get tapToReveal => 'Tap to reveal fully';

  @override
  String get tafsirLabel => 'Al-Muyassar Tafsir';

  @override
  String get noResults => 'No matching results.';

  @override
  String get surahWord => 'Surah';

  @override
  String get ayahWord => 'Ayah';

  @override
  String searchResultSubtitle(String surah, int ayah) {
    return 'Surah $surah — Ayah $ayah';
  }

  @override
  String get quranLoadError =>
      'Could not load the Quran database. Please restart the app.';
}
