import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'audio_service.dart';
import 'quran_repository.dart';

/// نقطة الدخول الرئيسية لتطبيق "نور القلوب".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  // تحميل قاعدة البيانات المحلية للقرآن والتفسير مسبقاً.
  try {
    await QuranRepository.instance.load();
  } catch (_) {
    // في حال فشل التحميل تعمل الشاشات بوضع مبسّط دون تعطّل التطبيق.
  }
  runApp(const NourAlQoloobApp());
}

/// رابط تلاوة تجريبي (بث) للتحقّق من عمل مشغّل الصوتيات للمقرئين.
const String kSampleRecitationUrl =
    'https://server8.mp3quran.net/afs/001.mp3';

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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: RecitationPlayerBar(
            url: kSampleRecitationUrl,
            title: 'استماع لتلاوة القارئ',
            subtitle: 'بث مباشر لتلاوة تجريبية للتأكّد من عمل المشغّل',
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
            itemCount: list.length,
            itemBuilder: (context, i) => DhikrCard(dhikr: list[i]),
          ),
        ),
      ],
    );
  }
}

/// شريط تشغيل تلاوة يعتمد على [AudioService] مع زر تشغيل/إيقاف تفاعلي.
class RecitationPlayerBar extends StatelessWidget {
  final String url;
  final String title;
  final String subtitle;
  const RecitationPlayerBar({
    super.key,
    required this.url,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: StreamBuilder<bool>(
        stream: AudioService.instance.playingStream,
        builder: (context, snapshot) {
          final isThis = AudioService.instance.currentUrl == url;
          final playing = isThis && (snapshot.data ?? false);
          return ListTile(
            leading: Icon(playing ? Icons.graphic_eq : Icons.headphones,
                size: 30),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              iconSize: 40,
              icon: Icon(playing
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill),
              onPressed: () async {
                try {
                  await AudioService.instance.toggle(url);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'تعذّر تشغيل الصوت (تحقّق من الاتصال بالإنترنت)')),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
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
      await AudioService.instance.play(_adhanUrl);
      _snack('جارٍ تشغيل الأذان');
    } catch (_) {
      _snack('تعذّر تشغيل الأذان (تحقّق من الاتصال بالإنترنت)');
    }
  }

  Future<void> _stopAdhan() async {
    try {
      await AudioService.instance.stop();
    } catch (_) {}
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
/// شاشة القرآن الكريم:
/// - قاعدة بيانات محلية حقيقية (النص العثماني + التفسير الميسّر).
/// - بحث داخل الآيات والتفسير.
/// - وضع الحفظ بإخفاء تدريجي للكلمات (نسبة قابلة للضبط) وتظليل قابل للكشف.
/// - قوائم منسدلة للتنقّل بين السور، ودعم الوضع العرضي لتكبير الخط.
/// ===========================================================================
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final _repo = QuranRepository.instance;
  final TextEditingController _searchController = TextEditingController();

  int _surahIndex = 0;
  bool _memorizeMode = false;
  bool _showTafsir = false;
  // نسبة الإخفاء في وضع الحفظ: 0 لا شيء، 1 إخفاء كامل.
  double _hideRatio = 1.0;
  final Set<int> _revealed = {};
  List<SearchHit> _searchResults = const [];
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectSurah(int? i) {
    if (i == null) return;
    setState(() {
      _surahIndex = i;
      _revealed.clear();
    });
  }

  void _runSearch(String query) {
    if (!_repo.isLoaded) return;
    setState(() {
      _searching = query.trim().isNotEmpty;
      _searchResults = _repo.search(query);
    });
  }

  void _openHit(SearchHit hit) {
    final idx =
        _repo.surahs.indexWhere((s) => s.number == hit.surah.number);
    if (idx < 0) return;
    setState(() {
      _surahIndex = idx;
      _searchController.clear();
      _searching = false;
      _searchResults = const [];
      _revealed.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_repo.isLoaded) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'تعذّر تحميل قاعدة بيانات القرآن. يرجى إعادة تشغيل التطبيق.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final surah = _repo.surahs[_surahIndex];
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        // تكبير الخط في الوضع العرضي لتسهيل القراءة والحفظ.
        final verseFontSize = isLandscape ? 32.0 : 23.0;
        return Column(
          children: [
            _buildControls(surah),
            if (_searching)
              Expanded(child: _buildSearchResults(verseFontSize))
            else
              Expanded(child: _buildSurahView(surah, verseFontSize)),
          ],
        );
      },
    );
  }

  Widget _buildControls(QuranSurah surah) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث في الآيات والتفسير…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _runSearch('');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: _runSearch,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _surahIndex,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'اختر السورة',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (var i = 0; i < _repo.surahs.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                            '${_repo.surahs[i].number}. سورة ${_repo.surahs[i].name}'),
                      ),
                  ],
                  onChanged: _selectSurah,
                ),
              ),
              const SizedBox(width: 8),
              _labeledSwitch(
                label: 'التفسير',
                value: _showTafsir,
                onChanged: (v) => setState(() => _showTafsir = v),
              ),
              _labeledSwitch(
                label: 'الحفظ',
                value: _memorizeMode,
                onChanged: (v) => setState(() {
                  _memorizeMode = v;
                  _revealed.clear();
                }),
              ),
            ],
          ),
          if (_memorizeMode) _buildMemorizeControls(),
        ],
      ),
    );
  }

  Widget _labeledSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildMemorizeControls() {
    return Column(
      children: [
        Row(
          children: [
            const Text('مقدار الإخفاء', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Slider(
                value: _hideRatio,
                divisions: 4,
                label: '${(_hideRatio * 100).round()}%',
                onChanged: (v) => setState(() {
                  _hideRatio = v;
                  _revealed.clear();
                }),
              ),
            ),
            Text('${(_hideRatio * 100).round()}%',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        const Text(
          'اقرأ الجزء الظاهر ثم اضغط على الآية لكشفها كاملة للتسميع.',
          style: TextStyle(color: Colors.teal, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSurahView(QuranSurah surah, double fontSize) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
      itemCount: surah.ayahs.length,
      itemBuilder: (context, i) {
        final ayah = surah.ayahs[i];
        final revealed = _revealed.contains(i);
        final hide = _memorizeMode && !revealed;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            onTap: _memorizeMode
                ? () => setState(() {
                      if (revealed) {
                        _revealed.remove(i);
                      } else {
                        _revealed.add(i);
                      }
                    })
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text('${ayah.number}',
                            style: const TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: hide
                            ? _HiddenVerse(
                                text: ayah.text,
                                fontSize: fontSize,
                                hideRatio: _hideRatio,
                              )
                            : Text(
                                ayah.text,
                                style: TextStyle(
                                    fontSize: fontSize, height: 2.0),
                                textAlign: TextAlign.right,
                              ),
                      ),
                    ],
                  ),
                  if (_showTafsir && !hide) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            size: 18, color: Colors.teal),
                        const SizedBox(width: 6),
                        Text('التفسير الميسّر',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ayah.tafsir,
                      style: const TextStyle(fontSize: 16, height: 1.7),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(double fontSize) {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('لا توجد نتائج مطابقة.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
      itemCount: _searchResults.length,
      itemBuilder: (context, i) {
        final hit = _searchResults[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            onTap: () => _openHit(hit),
            title: Text(
              hit.ayah.text,
              style: const TextStyle(fontSize: 19, height: 1.9),
              textAlign: TextAlign.right,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'سورة ${hit.surah.name} — الآية ${hit.ayah.number}',
                style: TextStyle(color: Colors.teal.shade700),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// عرض آية بوضع الحفظ مع إخفاء نسبة من كلماتها تدريجياً.
class _HiddenVerse extends StatelessWidget {
  final String text;
  final double fontSize;
  final double hideRatio;
  const _HiddenVerse({
    required this.text,
    required this.fontSize,
    required this.hideRatio,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    // عدد الكلمات المخفيّة من نهاية الآية بحسب النسبة المختارة.
    final hideCount = (words.length * hideRatio).round().clamp(0, words.length);
    final visibleCount = words.length - hideCount;
    final maskColor = Colors.grey.shade300;

    final spans = <InlineSpan>[];
    for (var i = 0; i < words.length; i++) {
      final hidden = i >= visibleCount;
      if (hidden) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: maskColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '•' * words[i].characters.length.clamp(2, 8),
              style: TextStyle(fontSize: fontSize, color: maskColor),
            ),
          ),
        ));
      } else {
        spans.add(TextSpan(text: '${words[i]} '));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: fontSize, height: 2.0),
            children: spans,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.touch_app, size: 15, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text('اضغط للكشف الكامل',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ],
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
