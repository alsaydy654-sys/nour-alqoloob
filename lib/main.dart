import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'audio_service.dart';
import 'content_repository.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'quran_repository.dart';

/// نقطة الدخول الرئيسية لتطبيق "نور القلوب".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await LocaleController.instance.load();
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

/// الجذر الأساسي للتطبيق مع دعم تعدّد اللغات واتجاه RTL/LTR تلقائياً.
class NourAlQoloobApp extends StatelessWidget {
  const NourAlQoloobApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1B5E4F);
    return AnimatedBuilder(
      animation: LocaleController.instance,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seed,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          locale: LocaleController.instance.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeShell(),
        );
      },
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

  @override
  void initState() {
    super.initState();
    NotificationService.instance.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final titles = [t.titleAdhkar, t.titleDuas, t.titlePrayer, t.titleQuran];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            tooltip: _showTasbeeh ? t.hideTasbeeh : t.showTasbeeh,
            icon: Icon(_showTasbeeh
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked),
            onPressed: () => setState(() => _showTasbeeh = !_showTasbeeh),
          ),
          IconButton(
            tooltip: t.settings,
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
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
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.wb_sunny_outlined),
              selectedIcon: const Icon(Icons.wb_sunny),
              label: t.tabAdhkar),
          NavigationDestination(
              icon: const Icon(Icons.volunteer_activism_outlined),
              selectedIcon: const Icon(Icons.volunteer_activism),
              label: t.tabDuas),
          NavigationDestination(
              icon: const Icon(Icons.access_time_outlined),
              selectedIcon: const Icon(Icons.access_time_filled),
              label: t.tabPrayer),
          NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: t.tabQuran),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// شاشة الإعدادات: اختيار اللغة يدوياً أو اتباع لغة الجهاز.
/// ===========================================================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _nativeNames = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'ur': 'اردو',
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final current = LocaleController.instance.locale;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(t.language,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          RadioGroup<Locale?>(
            groupValue: current,
            onChanged: (v) => LocaleController.instance.setLocale(v),
            child: Column(
              children: [
                RadioListTile<Locale?>(
                  title: Text(t.languageSystem),
                  value: null,
                ),
                for (final locale in kSupportedLocales)
                  RadioListTile<Locale?>(
                    title: Text(_nativeNames[locale.languageCode] ??
                        locale.languageCode),
                    value: locale,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// شاشة الأذكار الذكية: تختار الصباح/المساء تلقائياً حسب الوقت.
/// ===========================================================================
class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  bool _isMorning = true;
  AppContent? _content;
  String? _loadedLang;

  @override
  void initState() {
    super.initState();
    _isMorning = _detectMorning();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureContent();
  }

  Future<void> _ensureContent() async {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == _loadedLang) return;
    final content = await ContentRepository.instance.forLanguage(lang);
    if (!mounted) return;
    setState(() {
      _content = content;
      _loadedLang = lang;
    });
  }

  /// اعتبار الفترة من الرابعة صباحاً حتى الرابعة عصراً "صباحاً".
  bool _detectMorning() {
    final hour = DateTime.now().hour;
    return hour >= 4 && hour < 16;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final content = _content;
    if (content == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final list = _isMorning ? content.morning : content.evening;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                  value: true,
                  label: Text(t.adhkarMorning),
                  icon: const Icon(Icons.wb_sunny)),
              ButtonSegment(
                  value: false,
                  label: Text(t.adhkarEvening),
                  icon: const Icon(Icons.nightlight_round)),
            ],
            selected: {_isMorning},
            onSelectionChanged: (s) => setState(() => _isMorning = s.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: RecitationPlayerBar(
            url: kSampleRecitationUrl,
            title: t.listenReciter,
            subtitle: t.listenReciterSubtitle,
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
    final t = AppLocalizations.of(context);
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
                      SnackBar(content: Text(t.audioError)),
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

/// بطاقة ذِكر مع عدّاد تفاعلي، تعرض النص العربي وترجمة المعنى إن وُجدت.
class DhikrCard extends StatefulWidget {
  final LocalizedDhikr dhikr;
  const DhikrCard({super.key, required this.dhikr});

  @override
  State<DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<DhikrCard> {
  int _done = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final finished = _done >= widget.dhikr.count;
    final translation = widget.dhikr.translation;
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
                widget.dhikr.arabic,
                style: const TextStyle(fontSize: 20, height: 1.8),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              if (translation.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  translation,
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.outline),
                ),
              ],
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
                    Text(t.tapToCount,
                        style: const TextStyle(color: Colors.grey)),
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
class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  List<LocalizedDua>? _duas;
  String? _loadedLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureContent();
  }

  Future<void> _ensureContent() async {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == _loadedLang) return;
    final content = await ContentRepository.instance.forLanguage(lang);
    if (!mounted) return;
    setState(() {
      _duas = content.duas;
      _loadedLang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final duas = _duas;
    if (duas == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      itemCount: duas.length,
      itemBuilder: (context, i) {
        final d = duas[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ExpansionTile(
            leading: const Icon(Icons.volunteer_activism),
            title: Text(d.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              Text(d.arabic,
                  style: const TextStyle(fontSize: 19, height: 1.8),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl),
              if (d.translation.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(d.translation,
                    style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Theme.of(context).colorScheme.outline)),
              ],
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
  final int hour;
  final int minute;
  const PrayerTime(this.hour, this.minute);

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
    PrayerTime(4, 30),
    PrayerTime(12, 15),
    PrayerTime(15, 45),
    PrayerTime(18, 40),
    PrayerTime(20, 10),
  ];

  static const _adhanUrl =
      'https://www.islamcan.com/audio/adhan/azan2.mp3';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  List<String> _prayerNames(AppLocalizations t) => [
        t.prayerFajr,
        t.prayerDhuhr,
        t.prayerAsr,
        t.prayerMaghrib,
        t.prayerIsha,
      ];

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _alertsEnabled = prefs.getBool('alerts_enabled') ?? false);
  }

  Future<void> _toggleAlerts(bool value) async {
    final t = AppLocalizations.of(context);
    final names = _prayerNames(t);
    setState(() => _alertsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alerts_enabled', value);
    if (value) {
      for (var i = 0; i < _times.length; i++) {
        final time = _times[i];
        await NotificationService.instance.scheduleDaily(
          100 + i,
          t.prayerNotifTitle(names[i]),
          t.prayerNotifBody,
          time.hour,
          time.minute,
        );
      }
      _snack(t.alertsOn);
    } else {
      for (var i = 0; i < _times.length; i++) {
        await NotificationService.instance.cancel(100 + i);
      }
      _snack(t.alertsOff);
    }
  }

  Future<void> _playAdhan() async {
    final t = AppLocalizations.of(context);
    try {
      await AudioService.instance.play(_adhanUrl);
      _snack(t.playingAdhan);
    } catch (_) {
      _snack(t.adhanError);
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
    final t = AppLocalizations.of(context);
    final names = _prayerNames(t);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      children: [
        SwitchListTile(
          title: Text(t.prayerAlertsTitle),
          subtitle: Text(t.prayerAlertsSubtitle),
          value: _alertsEnabled,
          onChanged: _toggleAlerts,
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _times.length; i++)
          Card(
            child: ListTile(
              leading: const Icon(Icons.mosque, size: 32),
              title: Text(names[i],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              trailing: Text(_times[i].formatted,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _playAdhan,
                icon: const Icon(Icons.play_arrow),
                label: Text(t.playAdhan),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _stopAdhan,
                icon: const Icon(Icons.stop),
                label: Text(t.stop),
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
    final t = AppLocalizations.of(context);
    if (!_repo.isLoaded) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(t.quranLoadError, textAlign: TextAlign.center),
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
            _buildControls(t),
            if (_searching)
              Expanded(child: _buildSearchResults(t))
            else
              Expanded(child: _buildSurahView(t, surah, verseFontSize)),
          ],
        );
      },
    );
  }

  Widget _buildControls(AppLocalizations t) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: t.quranSearchHint,
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
                  decoration: InputDecoration(
                    labelText: t.chooseSurah,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (var i = 0; i < _repo.surahs.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(_surahLabel(t, i, isArabic)),
                      ),
                  ],
                  onChanged: _selectSurah,
                ),
              ),
              const SizedBox(width: 8),
              _labeledSwitch(
                label: t.tafsir,
                value: _showTafsir,
                onChanged: (v) => setState(() => _showTafsir = v),
              ),
              _labeledSwitch(
                label: t.memorize,
                value: _memorizeMode,
                onChanged: (v) => setState(() {
                  _memorizeMode = v;
                  _revealed.clear();
                }),
              ),
            ],
          ),
          if (_memorizeMode) _buildMemorizeControls(t),
        ],
      ),
    );
  }

  /// اسم السورة في القائمة: بالعربية للعرب، وبالاسم اللاتيني لغيرها.
  String _surahLabel(AppLocalizations t, int i, bool isArabic) {
    final s = _repo.surahs[i];
    if (isArabic) return '${s.number}. ${t.surahWord} ${s.name}';
    return '${s.number}. ${t.surahWord} ${s.englishName}';
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

  Widget _buildMemorizeControls(AppLocalizations t) {
    return Column(
      children: [
        Row(
          children: [
            Text(t.hideAmount, style: const TextStyle(fontSize: 12)),
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
        Text(
          t.memorizeHint,
          style: const TextStyle(color: Colors.teal, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSurahView(
      AppLocalizations t, QuranSurah surah, double fontSize) {
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
                    textDirection: TextDirection.rtl,
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
                                hint: t.tapToReveal,
                              )
                            : Text(
                                ayah.text,
                                style: TextStyle(
                                    fontSize: fontSize, height: 2.0),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
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
                        Text(t.tafsirLabel,
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
                      textDirection: TextDirection.rtl,
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

  Widget _buildSearchResults(AppLocalizations t) {
    if (_searchResults.isEmpty) {
      return Center(child: Text(t.noResults));
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
              textDirection: TextDirection.rtl,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                t.searchResultSubtitle(hit.surah.name, hit.ayah.number),
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
  final String hint;
  const _HiddenVerse({
    required this.text,
    required this.fontSize,
    required this.hideRatio,
    required this.hint,
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
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.touch_app, size: 15, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(hint,
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
