import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_service.dart';
import 'content_repository.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'notification_service.dart';
import 'overlay_tasbeeh.dart';
import 'prayer_times_service.dart';
import 'quran_repository.dart';
import 'reciters.dart';
import 'settings_controller.dart';

/// نقطة الدخول الرئيسية لتطبيق "نور القلوب".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await LocaleController.instance.load();
  await SettingsController.instance.load();
  // تحميل قاعدة البيانات المحلية للقرآن والتفسير مسبقاً.
  try {
    await QuranRepository.instance.load();
  } catch (_) {
    // في حال فشل التحميل تعمل الشاشات بوضع مبسّط دون تعطّل التطبيق.
  }
  runApp(const NourAlQoloobApp());
}

/// نقطة دخول النافذة العائمة للمسبحة (يستدعيها المكوّن الأصلي على أندرويد).
@pragma('vm:entry-point')
void overlayMain() => runOverlayTasbeeh();

/// الجذر الأساسي للتطبيق: تعدّد اللغات، اتجاه RTL/LTR تلقائي، سمة وحجم خط.
class NourAlQoloobApp extends StatelessWidget {
  const NourAlQoloobApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1B5E4F);
    final settings = SettingsController.instance;
    return AnimatedBuilder(
      animation:
          Listenable.merge([LocaleController.instance, settings]),
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
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seed,
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          themeMode: settings.themeMode,
          locale: LocaleController.instance.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // تطبيق حجم الخط المختار على كل النصوص.
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: settings.fontScale,
            maxScaleFactor: settings.fontScale,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const HomeShell(),
        );
      },
    );
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
/// شاشة الإعدادات الشاملة: اللغة، السمة، حجم الخط، المقرئ، التنبيهات،
/// الموقع الجغرافي، والمسبحة العائمة فوق التطبيقات.
/// ===========================================================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _nativeNames = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'ur': 'اردو',
  };

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsController.instance;
  bool _locating = false;
  bool _overlayActive = false;

  @override
  void initState() {
    super.initState();
    _refreshOverlayState();
  }

  Future<void> _refreshOverlayState() async {
    final active = await OverlayTasbeehService.instance.isActive();
    if (!mounted) return;
    setState(() => _overlayActive = active);
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleGps(bool value) async {
    final t = AppLocalizations.of(context);
    await _settings.setUseGps(value);
    if (!value) return;
    setState(() => _locating = true);
    final status = await PrayerTimesService.instance.refreshLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    if (status != LocationStatus.ok) {
      _snack(t.locationDenied);
      await _settings.setUseGps(false);
    }
  }

  Future<void> _toggleReminders(bool value) async {
    final t = AppLocalizations.of(context);
    await _settings.setDhikrReminders(value);
    if (!NotificationService.instance.available) {
      _snack(t.notificationsUnavailable);
      return;
    }
    if (value) {
      await NotificationService.instance.scheduleDhikrReminders(
        _settings.reminderHours,
        [
          DhikrReminder(t.reminderTitleIstighfar, t.reminderBodyIstighfar),
          DhikrReminder(t.reminderTitleTasbih, t.reminderBodyTasbih),
          DhikrReminder(t.reminderTitleSalat, t.reminderBodySalat),
        ],
      );
      _snack(t.remindersOn);
    } else {
      await NotificationService.instance.cancelDhikrReminders();
      _snack(t.remindersOff);
    }
  }

  Future<void> _toggleOverlay(bool value) async {
    final t = AppLocalizations.of(context);
    if (!OverlayTasbeehService.instance.isSupported) {
      _snack(t.overlayUnsupported);
      return;
    }
    if (value) {
      final result = await OverlayTasbeehService.instance.start();
      if (result == OverlayStartResult.permissionRequired) {
        _snack(t.overlayPermissionNeeded);
      }
    } else {
      await OverlayTasbeehService.instance.stop();
    }
    await _refreshOverlayState();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isArabicScript =
        ['ar', 'ur'].contains(Localizations.localeOf(context).languageCode);
    return AnimatedBuilder(
      animation: Listenable.merge([_settings, LocaleController.instance]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(t.settings)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _sectionTitle(t.language),
            RadioGroup<Locale?>(
              groupValue: LocaleController.instance.locale,
              onChanged: (v) => LocaleController.instance.setLocale(v),
              child: Column(
                children: [
                  RadioListTile<Locale?>(
                      title: Text(t.languageSystem), value: null),
                  for (final locale in kSupportedLocales)
                    RadioListTile<Locale?>(
                      title: Text(
                          SettingsScreen._nativeNames[locale.languageCode] ??
                              locale.languageCode),
                      value: locale,
                    ),
                ],
              ),
            ),
            const Divider(),
            _sectionTitle(t.appearance),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(t.theme),
              trailing: DropdownButton<ThemeMode>(
                value: _settings.themeMode,
                onChanged: (v) =>
                    v == null ? null : _settings.setThemeMode(v),
                items: [
                  DropdownMenuItem(
                      value: ThemeMode.system, child: Text(t.themeSystem)),
                  DropdownMenuItem(
                      value: ThemeMode.light, child: Text(t.themeLight)),
                  DropdownMenuItem(
                      value: ThemeMode.dark, child: Text(t.themeDark)),
                ],
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: Text(t.themeDark),
              value: _settings.themeMode == ThemeMode.dark,
              onChanged: (v) => _settings
                  .setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
            ),
            ListTile(
              leading: const Icon(Icons.format_size),
              title: Text(t.fontSize),
              subtitle: Slider(
                value: _settings.fontScale,
                min: 0.8,
                max: 1.6,
                divisions: 8,
                label: '${(_settings.fontScale * 100).round()}%',
                onChanged: (v) => _settings.setFontScale(v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                t.fontSizePreview,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
            const Divider(),
            _sectionTitle(t.reciter),
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: Text(t.reciter),
              subtitle: DropdownButton<String>(
                isExpanded: true,
                value: _settings.reciterId,
                onChanged: (v) => v == null ? null : _settings.setReciter(v),
                items: [
                  for (final reciter in kReciters)
                    DropdownMenuItem(
                      value: reciter.id,
                      child: Text(isArabicScript
                          ? reciter.arabicName
                          : reciter.latinName),
                    ),
                ],
              ),
            ),
            const Divider(),
            _sectionTitle(t.prayerSection),
            SwitchListTile(
              secondary: const Icon(Icons.my_location),
              title: Text(t.useGps),
              subtitle: _locating
                  ? Text(t.locating)
                  : _settings.useGps && _settings.hasLocation
                      ? Text(t.locationCoords(
                          _settings.latitude!.toStringAsFixed(3),
                          _settings.longitude!.toStringAsFixed(3)))
                      : Text(t.defaultLocationNotice),
              value: _settings.useGps,
              onChanged: _locating ? null : _toggleGps,
            ),
            if (_settings.useGps)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(t.refreshLocation),
                onTap: _locating ? null : () => _toggleGps(true),
              ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active),
              title: Text(t.remindersTitle),
              subtitle: Text(t.remindersSubtitle),
              value: _settings.dhikrReminders,
              onChanged: _toggleReminders,
            ),
            if (_settings.dhikrReminders)
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(t.reminderInterval),
                trailing: DropdownButton<int>(
                  value: _settings.reminderHours,
                  onChanged: (v) async {
                    if (v == null) return;
                    await _settings.setReminderHours(v);
                    await _toggleReminders(true);
                  },
                  items: [
                    for (final hours
                        in SettingsController.reminderHourOptions)
                      DropdownMenuItem(
                          value: hours, child: Text(t.everyNHours(hours))),
                  ],
                ),
              ),
            const Divider(),
            _sectionTitle(t.tasbeehSection),
            SwitchListTile(
              secondary: const Icon(Icons.vibration),
              title: Text(t.vibrateOnTap),
              value: _settings.vibrate,
              onChanged: _settings.setVibrate,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.picture_in_picture_alt),
              title: Text(t.overlayTasbeeh),
              subtitle: Text(OverlayTasbeehService.instance.isSupported
                  ? t.overlaySubtitle
                  : t.overlayUnsupported),
              value: _overlayActive,
              onChanged: OverlayTasbeehService.instance.isSupported
                  ? _toggleOverlay
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );
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
    return AnimatedBuilder(
      animation: SettingsController.instance,
      builder: (context, _) {
        final reciter = SettingsController.instance.reciter;
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
                onSelectionChanged: (s) =>
                    setState(() => _isMorning = s.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: RecitationPlayerBar(
                url: reciter.urlForSurah(1),
                title: t.listenReciter,
                subtitle: Localizations.localeOf(context).languageCode == 'ar'
                    ? reciter.arabicName
                    : reciter.latinName,
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
      },
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
            leading:
                Icon(playing ? Icons.graphic_eq : Icons.headphones, size: 30),
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
          if (finished) return;
          if (SettingsController.instance.vibrate) {
            HapticFeedback.lightImpact();
          }
          setState(() => _done++);
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
                    backgroundColor:
                        finished ? Colors.green.withValues(alpha: 0.2) : null,
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
/// شاشة مواقيت الصلاة: تُحسَب من موقع المستخدم (GPS) عبر حزمة adhan،
/// مع تنبيهات أذان تعمل في الخلفية.
/// ===========================================================================
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _settings = SettingsController.instance;
  DailyPrayerTimes _times = PrayerTimesService.instance.today();
  bool _locating = false;

  static const _adhanUrl = 'https://www.islamcan.com/audio/adhan/azan2.mp3';

  List<String> _prayerNames(AppLocalizations t) => [
        t.prayerFajr,
        t.prayerDhuhr,
        t.prayerAsr,
        t.prayerMaghrib,
        t.prayerIsha,
      ];

  String _format(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  void _recompute() =>
      setState(() => _times = PrayerTimesService.instance.today());

  Future<void> _useMyLocation() async {
    final t = AppLocalizations.of(context);
    setState(() => _locating = true);
    await _settings.setUseGps(true);
    final status = await PrayerTimesService.instance.refreshLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    if (status == LocationStatus.ok) {
      _recompute();
      if (_settings.prayerAlerts) await _reschedule();
    } else {
      await _settings.setUseGps(false);
      _snack(t.locationDenied);
      _recompute();
    }
  }

  Future<void> _reschedule() async {
    final t = AppLocalizations.of(context);
    final names = _prayerNames(t);
    await NotificationService.instance.schedulePrayers(
      _times.obligatory,
      [for (final name in names) t.prayerNotifTitle(name)],
      t.prayerNotifBody,
    );
  }

  Future<void> _toggleAlerts(bool value) async {
    final t = AppLocalizations.of(context);
    await _settings.setPrayerAlerts(value);
    if (!NotificationService.instance.available) {
      _snack(t.notificationsUnavailable);
      return;
    }
    if (value) {
      await _reschedule();
      _snack(t.alertsOn);
    } else {
      await NotificationService.instance.cancelPrayers();
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
    final nextIndex = _times.nextPrayerIndex(DateTime.now());
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.place),
              title: Text(t.nextPrayer(names[nextIndex])),
              subtitle: _locating
                  ? Text(t.locating)
                  : _times.fromDeviceLocation && _settings.hasLocation
                      ? Text(t.locationCoords(
                          _settings.latitude!.toStringAsFixed(3),
                          _settings.longitude!.toStringAsFixed(3)))
                      : Text(t.defaultLocationNotice),
              trailing: IconButton(
                tooltip: t.useGps,
                icon: const Icon(Icons.my_location),
                onPressed: _locating ? null : _useMyLocation,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(t.prayerAlertsTitle),
            subtitle: Text(t.prayerAlertsSubtitle),
            value: _settings.prayerAlerts,
            onChanged: _toggleAlerts,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < names.length; i++)
            Card(
              color: i == nextIndex
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: ListTile(
                leading: const Icon(Icons.mosque, size: 32),
                title: Text(names[i],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                trailing: Text(_format(_times.obligatory[i]),
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.wb_twilight, size: 28),
              title: Text(t.prayerSunrise),
              trailing: Text(_format(_times.sunrise),
                  style: const TextStyle(fontSize: 18)),
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
      ),
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
    final idx = _repo.surahs.indexWhere((s) => s.number == hit.surah.number);
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
/// المسبحة الرقمية العائمة داخل التطبيق (قابلة للسحب، باهتزاز خفيف).
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
    setState(() => _count = prefs.getInt(kTasbeehCountKey) ?? 0);
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kTasbeehCountKey, _count);
  }

  void _increment() {
    if (SettingsController.instance.vibrate) HapticFeedback.lightImpact();
    setState(() => _count++);
    _saveCount();
  }

  void _reset() {
    if (SettingsController.instance.vibrate) HapticFeedback.mediumImpact();
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
            final dx =
                (_position.dx + details.delta.dx).clamp(0.0, size.width - 80);
            final dy =
                (_position.dy + details.delta.dy).clamp(0.0, size.height - 160);
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
