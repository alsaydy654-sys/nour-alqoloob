import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

import 'settings_controller.dart';

/// إحداثيات مكة المكرمة تُستخدم كقيمة افتراضية عند تعذّر تحديد الموقع.
const double kMakkahLatitude = 21.4225;
const double kMakkahLongitude = 39.8262;

/// نتيجة محاولة تحديد الموقع.
enum LocationStatus { ok, denied, unavailable }

/// مواقيت الصلاة المحسوبة ليوم واحد.
class DailyPrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  /// هل حُسبت من موقع المستخدم الفعلي أم من الإحداثيات الافتراضية.
  final bool fromDeviceLocation;

  const DailyPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.fromDeviceLocation,
  });

  /// المواقيت الخمس المفروضة بالترتيب.
  List<DateTime> get obligatory => [fajr, dhuhr, asr, maghrib, isha];

  /// فهرس الصلاة القادمة ضمن [obligatory]، أو 0 (فجر الغد) بعد العشاء.
  int nextPrayerIndex(DateTime now) {
    for (var i = 0; i < obligatory.length; i++) {
      if (obligatory[i].isAfter(now)) return i;
    }
    return 0;
  }
}

/// يحسب مواقيت الصلاة عبر حزمة adhan اعتماداً على موقع المستخدم (GPS)،
/// مع الرجوع إلى إحداثيات محفوظة أو إلى مكة المكرمة عند تعذّر ذلك.
class PrayerTimesService {
  PrayerTimesService._();
  static final PrayerTimesService instance = PrayerTimesService._();

  /// يطلب إذن الموقع ويحدّث الإحداثيات المحفوظة في الإعدادات.
  Future<LocationStatus> refreshLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationStatus.unavailable;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationStatus.denied;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      );
      await SettingsController.instance
          .setCoordinates(position.latitude, position.longitude);
      return LocationStatus.ok;
    } catch (_) {
      return LocationStatus.unavailable;
    }
  }

  /// مواقيت اليوم بحسب الإحداثيات المحفوظة (أو مكة المكرمة كقيمة افتراضية).
  DailyPrayerTimes today() {
    final settings = SettingsController.instance;
    final useDeviceLocation = settings.useGps && settings.hasLocation;
    final coordinates = Coordinates(
      useDeviceLocation ? settings.latitude! : kMakkahLatitude,
      useDeviceLocation ? settings.longitude! : kMakkahLongitude,
    );
    final params = CalculationMethod.umm_al_qura.getParameters()
      ..madhab = Madhab.shafi;
    final times = PrayerTimes.today(coordinates, params);
    return DailyPrayerTimes(
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
      fromDeviceLocation: useDeviceLocation,
    );
  }
}
