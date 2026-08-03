import 'package:just_audio/just_audio.dart';

/// خدمة صوتية موحّدة تعتمد على just_audio لتشغيل التلاوات والأذان.
///
/// تحتفظ بمشغّل واحد مشترك حتى لا تتداخل مصادر الصوت، وتعرض حالة التشغيل
/// عبر [playingStream] لتحديث الأزرار في الواجهة.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();

  /// المصدر الصوتي المشغَّل حالياً (رابط) أو null عند التوقّف.
  String? _currentUrl;
  String? get currentUrl => _currentUrl;

  Stream<bool> get playingStream => _player.playingStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  bool get isPlaying => _player.playing;

  /// تشغيل مصدر صوتي عبر البث (Streaming) من رابط.
  Future<void> play(String url) async {
    if (_currentUrl != url) {
      await _player.setUrl(url);
      _currentUrl = url;
    }
    await _player.play();
  }

  /// تبديل التشغيل/الإيقاف لنفس المصدر.
  Future<void> toggle(String url) async {
    if (_currentUrl == url && _player.playing) {
      await pause();
    } else {
      await play(url);
    }
  }

  Future<void> pause() async => _player.pause();

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
  }

  Future<void> dispose() async => _player.dispose();
}
