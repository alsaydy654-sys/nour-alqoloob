import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// نقطة الدخول الرئيسية لتطبيق "نور القلوب".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const NourAlQoloobApp());
}

/// الجذر الأساسي للتطبيق مع دعم اللغة العربية والاتجاه من اليمين لليسار.
class NourAlQoloobApp extends StatelessWidget {
  const NourAlQoloobApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1B5E4F);
    return MaterialApp(
      title: 'نور القلوب',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.light,
        fontFamily: 'Amiri',
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      locale: const Locale('ar'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const HomeShell(),
    );
  }
}

/// ===========================================================================
/// خدمة التنبيهات المحلية (تُستخدم للأذكار والصلاة).
/// ===========================================================================
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
    } catch (_) {
      // في حال تعذّر تهيئة المناطق الزمنية نتجاهل الخطأ ونكمل.
    }
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    try {
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (_) {
      // بعض المنصّات (مثل الويب/سطح المكتب) قد لا تدعم التنبيهات.
      _initialized = false;
    }
  }

  Future<void> requestPermissions() async {
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

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'nour_alqoloob_channel',
          'تنبيهات نور القلوب',
          channelDescription: 'تنبيهات الأذكار ومواقيت الصلاة',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> showNow(int id, String title, String body) async {
    if (!_initialized) return;
    try {
      await _plugin.show(id, title, body, _details);
    } catch (_) {}
  }

  /// جدولة تنبيه يومي متكرر عند ساعة ودقيقة محدّدتين.
  Future<void> scheduleDaily(
    int id,
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    if (!_initialized) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOf(hour, minute),
        _details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> cancel(int id) async {
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

/// ===========================================================================
/// الهيكل الرئيسي: شريط التنقّل السفلي + المسبحة العائمة القابلة للسحب.
/// ===========================================================================
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _showTasbeeh = true;

  final List<Widget> _screens = const [
    AdhkarScreen(),
    DuaScreen(),
    PrayerTimesScreen(),
    QuranScreen(),
  ];

  final List<String> _titles = const [
    'الأذكار',
    'الأدعية المأثورة',
    'مواقيت الصلاة',
    'القرآن الكريم',
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: _showTasbeeh ? 'إخفاء المسبحة' : 'إظهار المسبحة',
            icon: Icon(_showTasbeeh
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked),
            onPressed: () => setState(() => _showTasbeeh = !_showTasbeeh),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _screens),
          if (_showTasbeeh) const FloatingTasbeeh(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny),
              label: 'الأذكار'),
          NavigationDestination(
              icon: Icon(Icons.volunteer_activism_outlined),
              selectedIcon: Icon(Icons.volunteer_activism),
              label: 'الأدعية'),
          NavigationDestination(
              icon: Icon(Icons.access_time_outlined),
              selectedIcon: Icon(Icons.access_time_filled),
              label: 'الصلاة'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'القرآن'),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// نموذج ذِكر واحد مع العداد المطلوب.
/// ===========================================================================
class Dhikr {
  final String text;
  final int count;
  const Dhikr(this.text, {this.count = 1});
}

const List<Dhikr> _morningAdhkar = [
  Dhikr(
      'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ.',
      count: 1),
  Dhikr('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.', count: 100),
  Dhikr(
      'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ (سيد الاستغفار).',
      count: 1),
  Dhikr('أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
      count: 3),
  Dhikr('لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ.', count: 10),
];

const List<Dhikr> _eveningAdhkar = [
  Dhikr(
      'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ.',
      count: 1),
  Dhikr('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.', count: 100),
  Dhikr('أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
      count: 3),
  Dhikr('اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ.',
      count: 1),
  Dhikr('حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ.',
      count: 7),
];

/// شاشة الأذكار الذكية: تختار الصباح/المساء تلقائياً حسب الوقت.
class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  bool _isMorning = true;

  @override
  void initState() {
    super.initState();
    _isMorning = _detectMorning();
  }

  /// اعتبار الفترة من الرابعة صباحاً حتى الرابعة عصراً "صباحاً".
  bool _detectMorning() {
    final hour = DateTime.now().hour;
    return hour >= 4 && hour < 16;
  }

  @override
  Widget build(BuildContext context) {
    final list = _isMorning ? _morningAdhkar : _eveningAdhkar;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                  value: true,
                  label: Text('أذكار الصباح'),
                  icon: Icon(Icons.wb_sunny)),
              ButtonSegment(
                  value: false,
                  label: Text('أذكار المساء'),
                  icon: Icon(Icons.nightlight_round)),
            ],
            selected: {_isMorning},
            onSelectionChanged: (s) => setState(() => _isMorning = s.first),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
            itemCount: list.length,
            itemBuilder: (context, i) => DhikrCard(dhikr: list[i]),
          ),
        ),
      ],
    );
  }
}

/// بطاقة ذِكر مع عدّاد تفاعلي.
class DhikrCard extends StatefulWidget {
  final Dhikr dhikr;
  const DhikrCard({super.key, required this.dhikr});

  @override
  State<DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<DhikrCard> {
  int _done = 0;

  @override
  Widget build(BuildContext context) {
    final finished = _done >= widget.dhikr.count;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          if (!finished) setState(() => _done++);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.dhikr.text,
                style: const TextStyle(fontSize: 20, height: 1.8),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text('$_done / ${widget.dhikr.count}'),
                    backgroundColor: finished
                        ? Colors.green.withValues(alpha: 0.2)
                        : null,
                  ),
                  if (finished)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    const Text('اضغط للعدّ',
                        style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// شاشة الأدعية المأثورة.
/// ===========================================================================
class DuaItem {
  final String title;
  final String text;
  const DuaItem(this.title, this.text);
}

const List<DuaItem> _duas = [
  DuaItem('دعاء الهمّ والحزن',
      'اللَّهُمَّ إِنِّي عَبْدُكَ ابْنُ عَبْدِكَ ابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ.'),
  DuaItem('دعاء الاستخارة',
      'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ.'),
  DuaItem('دعاء دخول المنزل',
      'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا.'),
  DuaItem('دعاء الكرب',
      'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ.'),
  DuaItem('جوامع الدعاء',
      'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.'),
];

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      itemCount: _duas.length,
      itemBuilder: (context, i) {
        final d = _duas[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ExpansionTile(
            leading: const Icon(Icons.volunteer_activism),
            title: Text(d.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              Text(d.text,
                  style: const TextStyle(fontSize: 19, height: 1.8),
                  textAlign: TextAlign.right),
            ],
          ),
        );
      },
    );
  }
}

/// ===========================================================================
/// شاشة مواقيت الصلاة مع التنبيهات الصوتية.
/// ===========================================================================
class PrayerTime {
  final String name;
  final int hour;
  final int minute;
  const PrayerTime(this.name, this.hour, this.minute);

  String get formatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _alertsEnabled = false;

  // مواقيت افتراضية (يمكن ربطها لاحقاً بواجهة برمجية للمواقيت الدقيقة).
  final List<PrayerTime> _times = const [
    PrayerTime('الفجر', 4, 30),
    PrayerTime('الظهر', 12, 15),
    PrayerTime('العصر', 15, 45),
    PrayerTime('المغرب', 18, 40),
    PrayerTime('العشاء', 20, 10),
  ];

  static const _adhanUrl =
      'https://www.islamcan.com/audio/adhan/azan2.mp3';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _alertsEnabled = prefs.getBool('alerts_enabled') ?? false);
  }

  Future<void> _toggleAlerts(bool value) async {
    setState(() => _alertsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alerts_enabled', value);
    if (value) {
      for (var i = 0; i < _times.length; i++) {
        final t = _times[i];
        await NotificationService.instance.scheduleDaily(
          100 + i,
          'حان الآن موعد ${t.name}',
          'الله أكبر، حيّ على الصلاة',
          t.hour,
          t.minute,
        );
      }
      _snack('تم تفعيل تنبيهات الصلاة');
    } else {
      for (var i = 0; i < _times.length; i++) {
        await NotificationService.instance.cancel(100 + i);
      }
      _snack('تم إيقاف تنبيهات الصلاة');
    }
  }

  Future<void> _playAdhan() async {
    try {
      await _player.setUrl(_adhanUrl);
      await _player.play();
      _snack('جارٍ تشغيل الأذان');
    } catch (_) {
      _snack('تعذّر تشغيل الأذان (تحقّق من الاتصال بالإنترنت)');
    }
  }

  Future<void> _stopAdhan() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      children: [
        SwitchListTile(
          title: const Text('تفعيل التنبيهات الصوتية للصلاة'),
          subtitle: const Text('يذكّرك بموعد كل صلاة يومياً'),
          value: _alertsEnabled,
          onChanged: _toggleAlerts,
        ),
        const SizedBox(height: 8),
        ..._times.map((t) => Card(
              child: ListTile(
                leading: const Icon(Icons.mosque, size: 32),
                title: Text(t.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                trailing: Text(t.formatted,
                    style: const TextStyle(fontSize: 20)),
              ),
            )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _playAdhan,
                icon: const Icon(Icons.play_arrow),
                label: const Text('تشغيل الأذان'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _stopAdhan,
                icon: const Icon(Icons.stop),
                label: const Text('إيقاف'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ===========================================================================
/// شاشة القرآن الكريم: وضع الحفظ + قوائم منسدلة + الوضع العرضي.
/// ===========================================================================
class Surah {
  final String name;
  final List<String> verses;
  const Surah(this.name, this.verses);
}

const List<Surah> _surahs = [
  Surah('الفاتحة', [
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'الرَّحْمَٰنِ الرَّحِيمِ',
    'مَالِكِ يَوْمِ الدِّينِ',
    'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
  ]),
  Surah('الإخلاص', [
    'قُلْ هُوَ اللَّهُ أَحَدٌ',
    'اللَّهُ الصَّمَدُ',
    'لَمْ يَلِدْ وَلَمْ يُولَدْ',
    'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
  ]),
  Surah('الفلق', [
    'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
    'مِن شَرِّ مَا خَلَقَ',
    'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
    'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
    'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
  ]),
  Surah('الناس', [
    'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    'مَلِكِ النَّاسِ',
    'إِلَٰهِ النَّاسِ',
    'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
    'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
    'مِنَ الْجِنَّةِ وَالنَّاسِ',
  ]),
];

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  int _surahIndex = 0;
  bool _memorizeMode = false;
  final Set<int> _revealed = {};

  void _selectSurah(int? i) {
    if (i == null) return;
    setState(() {
      _surahIndex = i;
      _revealed.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final surah = _surahs[_surahIndex];
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        // تكبير الخط في الوضع العرضي لتسهيل القراءة والحفظ.
        final verseFontSize = isLandscape ? 30.0 : 22.0;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _surahIndex,
                      decoration: const InputDecoration(
                        labelText: 'اختر السورة',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        for (var i = 0; i < _surahs.length; i++)
                          DropdownMenuItem(
                              value: i, child: Text('سورة ${_surahs[i].name}')),
                      ],
                      onChanged: _selectSurah,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      const Text('وضع الحفظ',
                          style: TextStyle(fontSize: 12)),
                      Switch(
                        value: _memorizeMode,
                        onChanged: (v) => setState(() {
                          _memorizeMode = v;
                          _revealed.clear();
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_memorizeMode && !isLandscape)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'وضع الحفظ مُفعّل: الآيات مخفية، اضغط على أي آية لإظهارها. '
                  'أدر الجهاز أفقياً لتكبير الخط.',
                  style: TextStyle(color: Colors.teal),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                itemCount: surah.verses.length,
                itemBuilder: (context, i) {
                  final hidden = _memorizeMode && !_revealed.contains(i);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: InkWell(
                      onTap: _memorizeMode
                          ? () => setState(() {
                                if (_revealed.contains(i)) {
                                  _revealed.remove(i);
                                } else {
                                  _revealed.add(i);
                                }
                              })
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              child: Text('${i + 1}',
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: hidden
                                  ? Row(
                                      children: [
                                        Icon(Icons.visibility_off,
                                            color: Colors.grey.shade400),
                                        const SizedBox(width: 8),
                                        Text('••••••  (اضغط للإظهار)',
                                            style: TextStyle(
                                                fontSize: verseFontSize,
                                                color: Colors.grey.shade400)),
                                      ],
                                    )
                                  : Text(
                                      surah.verses[i],
                                      style: TextStyle(
                                          fontSize: verseFontSize,
                                          height: 2.0),
                                      textAlign: TextAlign.right,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ===========================================================================
/// المسبحة الرقمية العائمة القابلة للسحب على الشاشة.
/// ===========================================================================
class FloatingTasbeeh extends StatefulWidget {
  const FloatingTasbeeh({super.key});

  @override
  State<FloatingTasbeeh> createState() => _FloatingTasbeehState();
}

class _FloatingTasbeehState extends State<FloatingTasbeeh> {
  Offset _position = const Offset(20, 120);
  int _count = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _count = prefs.getInt('tasbeeh_count') ?? 0);
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_count', _count);
  }

  void _increment() {
    setState(() => _count++);
    _saveCount();
  }

  void _reset() {
    setState(() => _count = 0);
    _saveCount();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!_initialized) {
      // وضع المسبحة أسفل يمين الشاشة افتراضياً عند أول رسم.
      _position = Offset(size.width - 96, size.height - 260);
      _initialized = true;
    }
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final dx = (_position.dx + details.delta.dx)
                .clamp(0.0, size.width - 80);
            final dy = (_position.dy + details.delta.dy)
                .clamp(0.0, size.height - 160);
            _position = Offset(dx, dy);
          });
        },
        onTap: _increment,
        onLongPress: _reset,
        child: Material(
          elevation: 8,
          shape: const CircleBorder(),
          color: Theme.of(context).colorScheme.primary,
          child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint, color: Colors.white, size: 24),
                Text(
                  '$_count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
