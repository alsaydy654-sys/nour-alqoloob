import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مفتاح عدّاد المسبحة المشترك بين التطبيق والنافذة العائمة.
const String kTasbeehCountKey = 'tasbeeh_count';

/// تشغيل واجهة النافذة العائمة (تعمل في محرّك Flutter منفصل فوق التطبيقات).
/// تُستدعى من نقطة الدخول `overlayMain` في `main.dart`.
@pragma('vm:entry-point')
void runOverlayTasbeeh() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _OverlayApp());
}

class _OverlayApp extends StatelessWidget {
  const _OverlayApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: OverlayTasbeehButton(),
      ),
    );
  }
}

/// زر المسبحة داخل النافذة العائمة: نقرة تزيد العدّاد باهتزاز خفيف،
/// وضغطة مطوّلة تصفّره، والقيمة تُحفَظ فوراً لتتزامن مع التطبيق.
class OverlayTasbeehButton extends StatefulWidget {
  const OverlayTasbeehButton({super.key});

  @override
  State<OverlayTasbeehButton> createState() => _OverlayTasbeehButtonState();
}

class _OverlayTasbeehButtonState extends State<OverlayTasbeehButton> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _count = prefs.getInt(kTasbeehCountKey) ?? 0);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kTasbeehCountKey, _count);
  }

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() => _count++);
    _save();
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() => _count = 0);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _increment,
        onLongPress: _reset,
        child: Material(
          elevation: 8,
          shape: const CircleBorder(),
          color: const Color(0xFF1B5E4F),
          child: SizedBox(
            width: 84,
            height: 84,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint, color: Colors.white, size: 22),
                Text(
                  '$_count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: FlutterOverlayWindow.closeOverlay,
                  child: const Icon(Icons.close,
                      color: Colors.white70, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// نتيجة محاولة تشغيل المسبحة العائمة فوق التطبيقات الأخرى.
enum OverlayStartResult { started, permissionRequired, unsupported }

/// إدارة نافذة المسبحة العائمة فوق التطبيقات (أندرويد فقط).
class OverlayTasbeehService {
  OverlayTasbeehService._();
  static final OverlayTasbeehService instance = OverlayTasbeehService._();

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> isActive() async {
    if (!isSupported) return false;
    try {
      return await FlutterOverlayWindow.isActive();
    } catch (_) {
      return false;
    }
  }

  Future<OverlayStartResult> start() async {
    if (!isSupported) return OverlayStartResult.unsupported;
    try {
      if (!await FlutterOverlayWindow.isPermissionGranted()) {
        await FlutterOverlayWindow.requestPermission();
        if (!await FlutterOverlayWindow.isPermissionGranted()) {
          return OverlayStartResult.permissionRequired;
        }
      }
      await FlutterOverlayWindow.showOverlay(
        height: 260,
        width: 260,
        alignment: OverlayAlignment.centerRight,
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        overlayTitle: 'نور القلوب',
        overlayContent: 'المسبحة الرقمية',
        enableDrag: true,
        positionGravity: PositionGravity.auto,
      );
      return OverlayStartResult.started;
    } catch (_) {
      return OverlayStartResult.unsupported;
    }
  }

  Future<void> stop() async {
    if (!isSupported) return;
    try {
      await FlutterOverlayWindow.closeOverlay();
    } catch (_) {}
  }
}
