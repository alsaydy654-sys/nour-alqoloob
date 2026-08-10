// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Nour Al-Qoloub';

  @override
  String get tabAdhkar => 'Adhkar';

  @override
  String get tabDuas => 'Invocations';

  @override
  String get tabPrayer => 'Prière';

  @override
  String get tabQuran => 'Coran';

  @override
  String get titleAdhkar => 'Adhkar';

  @override
  String get titleDuas => 'Invocations prophétiques';

  @override
  String get titlePrayer => 'Heures de prière';

  @override
  String get titleQuran => 'Le Saint Coran';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get showTasbeeh => 'Afficher le Tasbeeh';

  @override
  String get hideTasbeeh => 'Masquer le Tasbeeh';

  @override
  String get adhkarMorning => 'Adhkar du matin';

  @override
  String get adhkarEvening => 'Adhkar du soir';

  @override
  String get listenReciter => 'Écouter un récitateur';

  @override
  String get listenReciterSubtitle =>
      'Diffusion d\'une récitation d\'essai pour vérifier le lecteur';

  @override
  String get tapToCount => 'Appuyez pour compter';

  @override
  String get meaning => 'Signification';

  @override
  String get prayerAlertsTitle => 'Activer les alertes sonores de prière';

  @override
  String get prayerAlertsSubtitle =>
      'Vous rappelle chaque prière quotidiennement';

  @override
  String get playAdhan => 'Jouer l\'Adhan';

  @override
  String get stop => 'Arrêter';

  @override
  String get alertsOn => 'Alertes de prière activées';

  @override
  String get alertsOff => 'Alertes de prière désactivées';

  @override
  String get playingAdhan => 'Lecture de l\'Adhan';

  @override
  String get adhanError =>
      'Impossible de jouer l\'Adhan (vérifiez votre connexion Internet)';

  @override
  String get audioError =>
      'Impossible de lire l\'audio (vérifiez votre connexion Internet)';

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
    return 'C\'est maintenant l\'heure de $name';
  }

  @override
  String get prayerNotifBody => 'Allahou Akbar, venez à la prière';

  @override
  String get quranSearchHint => 'Rechercher dans les versets et le tafsir…';

  @override
  String get chooseSurah => 'Choisir la sourate';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get memorize => 'Mémoriser';

  @override
  String get hideAmount => 'Quantité masquée';

  @override
  String get memorizeHint =>
      'Lisez la partie visible, puis appuyez sur un verset pour l\'afficher entièrement.';

  @override
  String get tapToReveal => 'Appuyez pour tout afficher';

  @override
  String get tafsirLabel => 'Tafsir Al-Muyassar';

  @override
  String get noResults => 'Aucun résultat correspondant.';

  @override
  String get surahWord => 'Sourate';

  @override
  String get ayahWord => 'Verset';

  @override
  String searchResultSubtitle(String surah, int ayah) {
    return 'Sourate $surah — Verset $ayah';
  }

  @override
  String get quranLoadError =>
      'Impossible de charger la base de données du Coran. Veuillez redémarrer l\'application.';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Par défaut du système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Mode sombre';

  @override
  String get fontSize => 'Taille de police';

  @override
  String get fontSizePreview => 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';

  @override
  String get reciter => 'Récitateur préféré';

  @override
  String get prayerSection => 'Prière et alertes';

  @override
  String get location => 'Position';

  @override
  String get useGps => 'Calculer les heures selon ma position (GPS)';

  @override
  String get locating => 'Détection de la position…';

  @override
  String get locationDenied =>
      'Autorisation de localisation refusée ; heures de La Mecque utilisées';

  @override
  String locationCoords(String lat, String lng) {
    return 'Latitude $lat — Longitude $lng';
  }

  @override
  String get defaultLocationNotice => 'Heures par défaut (La Mecque)';

  @override
  String get refreshLocation => 'Actualiser la position';

  @override
  String nextPrayer(String name) {
    return 'Prochaine prière : $name';
  }

  @override
  String get prayerSunrise => 'Lever du soleil';

  @override
  String get remindersTitle => 'Rappels de dhikr périodiques';

  @override
  String get remindersSubtitle =>
      'Istighfar, tasbih et salat sur le Prophète, en arrière-plan';

  @override
  String get reminderInterval => 'Fréquence';

  @override
  String everyNHours(int hours) {
    return 'Toutes les $hours heures';
  }

  @override
  String get reminderTitleIstighfar => 'Heure de l\'Istighfar';

  @override
  String get reminderBodyIstighfar => 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ';

  @override
  String get reminderTitleTasbih => 'Heure du Tasbih';

  @override
  String get reminderBodyTasbih => 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ';

  @override
  String get reminderTitleSalat => 'Heure de la Salat sur le Prophète';

  @override
  String get reminderBodySalat =>
      'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ';

  @override
  String get remindersOn => 'Rappels de dhikr activés';

  @override
  String get remindersOff => 'Rappels de dhikr désactivés';

  @override
  String get tasbeehSection => 'Tasbeeh';

  @override
  String get overlayTasbeeh => 'Tasbeeh au-dessus des autres applis';

  @override
  String get overlaySubtitle =>
      'Flotte au-dessus de toute autre application avec le compteur';

  @override
  String get overlayEnable => 'Activer le Tasbeeh flottant';

  @override
  String get overlayDisable => 'Désactiver le Tasbeeh flottant';

  @override
  String get overlayPermissionNeeded =>
      'Veuillez autoriser « Affichage au-dessus des autres applis »';

  @override
  String get overlayUnsupported => 'Disponible uniquement sur Android';

  @override
  String get vibrateOnTap => 'Légère vibration au toucher';

  @override
  String get resetCounter => 'Réinitialiser le compteur';

  @override
  String get counterReset => 'Compteur réinitialisé';

  @override
  String get notificationsUnavailable =>
      'Les notifications ne sont pas prises en charge sur cette plateforme';
}
