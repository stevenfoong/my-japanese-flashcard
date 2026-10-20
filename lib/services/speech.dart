import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Plays Japanese sounds.
///
/// Kana and example words use the bundled VOICEVOX clips listed in
/// assets/audio/index.json. Anything without a clip falls back to the
/// phone's own text-to-speech voice.
class Speech {
  static final FlutterTts _tts = FlutterTts();
  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static bool _ttsReady = false;
  static Future<void>? _indexLoad;
  static Map<String, String> _clips = const {};

  /// Credit line for the bundled voice, e.g. "VOICEVOX:No.7"; null when there are no clips.
  static String? voiceCredit;

  static Future<void> loadIndex() => _indexLoad ??= _readIndex();

  static Future<void> _readIndex() async {
    try {
      final raw = await rootBundle.loadString('assets/audio/index.json');
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      _clips = Map<String, String>.from((data['clips'] as Map?) ?? const {});
      voiceCredit = _clips.isEmpty ? null : data['voice'] as String?;
    } catch (_) {
      _clips = const {};
    }
  }

  static bool hasClip(String text) => _clips.containsKey(text);

  static Future<void> speak(String text, {bool slow = false}) async {
    if (text.isEmpty) return;
    await loadIndex();
    final clip = _clips[text];
    if (clip != null) {
      try {
        await _tts.stop();
        await _player.stop();
        await _player.setPlaybackRate(slow ? 0.7 : 1.0);
        await _player.play(AssetSource('audio/$clip'));
        return;
      } catch (_) {
        // Fall through to the phone voice.
      }
    }
    await _speakTts(text, slow: slow);
  }

  static Future<void> _speakTts(String text, {required bool slow}) async {
    try {
      if (!_ttsReady) {
        await _tts.setLanguage('ja-JP');
        await _tts.setVolume(1.0);
        _ttsReady = true;
      }
      await _player.stop();
      await _tts.stop();
      await _tts.setSpeechRate(slow ? 0.2 : 0.45);
      await _tts.speak(text);
    } catch (_) {
      // No voice available; Settings explains how to install one.
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
