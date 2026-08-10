import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reciters.dart';

/// إعدادات المستخدم المحفوظة محلياً: السمة، حجم الخط، المقرئ، التنبيهات،
/// الموقع الجغرافي، وسلوك المسبحة.
class SettingsController extends ChangeNotifier {
  SettingsController._();
  static final SettingsController instance = SettingsController._();

  static const _kThemeMode = 'theme_mode';
  static const _kFontScale = 'font_scale';
  static const _kReciter = 'reciter_id';
  static const _kPrayerAlerts = 'alerts_enabled';
  static const _kDhikrReminders = 'dhikr_reminders';
  static const _kReminderHours = 'reminder_hours';
  static const _kUseGps = 'use_gps';
  static const _kLat = 'lat';
  static const _kLng = 'lng';
  static const _kVibrate = 'tasbeeh_vibrate';

  ThemeMode _themeMode = ThemeMode.system;
  double _fontScale = 1.0;
  String _reciterId = kReciters.first.id;
  bool _prayerAlerts = false;
  bool _dhikrReminders = false;
  int _reminderHours = 3;
  bool _useGps = false;
  double? _latitude;
  double? _longitude;
  bool _vibrate = true;

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  String get reciterId => _reciterId;
  Reciter get reciter => reciterById(_reciterId);
  bool get prayerAlerts => _prayerAlerts;
  bool get dhikrReminders => _dhikrReminders;
  int get reminderHours => _reminderHours;
  bool get useGps => _useGps;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get vibrate => _vibrate;
  bool get hasLocation => _latitude != null && _longitude != null;

  /// الخيارات المتاحة لتكرار تنبيهات الأذكار (بالساعات).
  static const List<int> reminderHourOptions = [1, 2, 3, 4, 6];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _themeModeFromName(prefs.getString(_kThemeMode));
    _fontScale = prefs.getDouble(_kFontScale) ?? 1.0;
    _reciterId = prefs.getString(_kReciter) ?? kReciters.first.id;
    _prayerAlerts = prefs.getBool(_kPrayerAlerts) ?? false;
    _dhikrReminders = prefs.getBool(_kDhikrReminders) ?? false;
    _reminderHours = prefs.getInt(_kReminderHours) ?? 3;
    _useGps = prefs.getBool(_kUseGps) ?? false;
    _latitude = prefs.getDouble(_kLat);
    _longitude = prefs.getDouble(_kLng);
    _vibrate = prefs.getBool(_kVibrate) ?? true;
  }

  static ThemeMode _themeModeFromName(String? name) {
    switch (name) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode.name);
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScale, scale);
  }

  Future<void> setReciter(String id) async {
    _reciterId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kReciter, id);
  }

  Future<void> setPrayerAlerts(bool value) async {
    _prayerAlerts = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrayerAlerts, value);
  }

  Future<void> setDhikrReminders(bool value) async {
    _dhikrReminders = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDhikrReminders, value);
  }

  Future<void> setReminderHours(int hours) async {
    _reminderHours = hours;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kReminderHours, hours);
  }

  Future<void> setUseGps(bool value) async {
    _useGps = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseGps, value);
  }

  Future<void> setCoordinates(double latitude, double longitude) async {
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLat, latitude);
    await prefs.setDouble(_kLng, longitude);
  }

  Future<void> setVibrate(bool value) async {
    _vibrate = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVibrate, value);
  }
}
