import 'package:flutter_tts/flutter_tts.dart';

/// Japanese text-to-speech using the phone's own voice.
///
/// Phase 1 uses this for the kana sounds too; bundled audio clips will
/// replace that once they are chosen.
class Speech {
  static final FlutterTts _tts = FlutterTts();
  static bool _ready = false;

  static Future<void> _init() async {
    if (_ready) return;
    await _tts.setLanguage('ja-JP');
    await _tts.setVolume(1.0);
    _ready = true;
  }

  static Future<void> speak(String text, {bool slow = false}) async {
    try {
      await _init();
      await _tts.stop();
      await _tts.setSpeechRate(slow ? 0.2 : 0.45);
      await _tts.speak(text);
    } catch (_) {
      // No voice available; the offline check in Settings explains how to fix it.
    }
  }

  /// true / false on Android, null when the phone cannot tell us.
  static Future<bool?> japaneseVoiceInstalled() async {
    try {
      final installed = await _tts.isLanguageInstalled('ja-JP');
      if (installed is bool) return installed;
      final available = await _tts.isLanguageAvailable('ja-JP');
      if (available is bool) return available;
    } catch (_) {}
    return null;
  }
}
