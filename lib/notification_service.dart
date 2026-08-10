import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// تنبيه ذِكر دوري (عنوان + نص).
class DhikrReminder {
  final String title;
  final String body;
  const DhikrReminder(this.title, this.body);
}

/// خدمة التنبيهات المحلية: تعمل في الخلفية عبر AlarmManager على أندرويد،
/// لذا تظهر التنبيهات حتى لو كان التطبيق مغلقاً.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// معرّفات تنبيهات الصلوات الخمس.
  static const int prayerIdBase = 100;

  /// معرّفات تنبيهات الأذكار الدورية.
  static const int reminderIdBase = 200;
  static const int reminderIdMax = 240;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// هل التنبيهات مدعومة ومهيّأة على هذه المنصّة.
  bool get available => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(await _resolveTimeZone()));
    } catch (_) {
      // في حال تعذّر تحديد المنطقة الزمنية نكمل بالمنطقة الافتراضية.
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    try {
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (_) {
      // بعض المنصّات (الويب/سطح المكتب) لا تدعم التنبيهات المحلية.
      _initialized = false;
    }
  }

  Future<String> _resolveTimeZone() async {
    // الاعتماد على فرق التوقيت المحلي لاختيار منطقة زمنية مكافئة.
    final offset = DateTime.now().timeZoneOffset;
    for (final location in tz.timeZoneDatabase.locations.values) {
      final now = tz.TZDateTime.now(location);
      if (now.timeZoneOffset == offset) return location.name;
    }
    return 'UTC';
  }

  Future<void> requestPermissions() async {
    if (!_initialized) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  NotificationDetails _details({required bool prayer}) => NotificationDetails(
        android: AndroidNotificationDetails(
          prayer ? 'nour_prayer_channel' : 'nour_dhikr_channel',
          prayer ? 'تنبيهات الأذان' : 'تنبيهات الأذكار',
          channelDescription: prayer
              ? 'تنبيه صوتي عند دخول وقت كل صلاة'
              : 'تنبيهات دورية للاستغفار والتسبيح والصلاة على النبي',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: const BigTextStyleInformation(''),
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      );

  Future<void> showNow(int id, String title, String body) async {
    if (!_initialized) return;
    try {
      await _plugin.show(id, title, body, _details(prayer: false));
    } catch (_) {}
  }

  /// جدولة تنبيه يومي متكرر عند ساعة ودقيقة محدّدتين.
  Future<void> scheduleDaily(
    int id,
    String title,
    String body,
    int hour,
    int minute, {
    bool prayer = false,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOf(hour, minute),
        _details(prayer: prayer),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  /// جدولة تنبيهات الصلوات الخمس اليومية من المواقيت المحسوبة.
  Future<void> schedulePrayers(
    List<DateTime> times,
    List<String> titles,
    String body,
  ) async {
    await cancelPrayers();
    for (var i = 0; i < times.length; i++) {
      await scheduleDaily(
        prayerIdBase + i,
        titles[i],
        body,
        times[i].hour,
        times[i].minute,
        prayer: true,
      );
    }
  }

  /// جدولة تنبيهات أذكار متفرقة كل [intervalHours] ساعة بين 6 صباحاً و10 مساءً،
  /// بتدوير الأذكار المُمرّرة (استغفار/تسبيح/صلاة على النبي).
  Future<void> scheduleDhikrReminders(
    int intervalHours,
    List<DhikrReminder> reminders,
  ) async {
    await cancelDhikrReminders();
    if (reminders.isEmpty || intervalHours <= 0) return;
    var id = reminderIdBase;
    var slot = 0;
    for (var hour = 6; hour <= 22 && id < reminderIdMax; hour += intervalHours) {
      final reminder = reminders[slot % reminders.length];
      await scheduleDaily(id, reminder.title, reminder.body, hour, 0);
      id++;
      slot++;
    }
  }

  Future<void> cancelPrayers() async {
    for (var i = 0; i < 5; i++) {
      await cancel(prayerIdBase + i);
    }
  }

  Future<void> cancelDhikrReminders() async {
    for (var id = reminderIdBase; id < reminderIdMax; id++) {
      await cancel(id);
    }
  }

  Future<void> cancel(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
