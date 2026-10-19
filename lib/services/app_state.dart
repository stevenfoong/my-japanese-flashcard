import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

enum Answer { again, gotIt }

/// What the app remembers about one card, for spaced repetition and mastery.
class CardProgress {
  CardProgress({this.box = 0, this.due = 0, List<String>? rightDays}) : rightDays = rightDays ?? [];

  /// 0 = still learning; each "Got it" moves it up a box and waits longer.
  int box;

  /// When the card should come back, in milliseconds since epoch.
  int due;

  /// Up to 3 different days the card was answered "Got it".
  List<String> rightDays;

  Map<String, dynamic> toJson() => {'b': box, 'd': due, 'r': rightDays};

  factory CardProgress.fromJson(Map<String, dynamic> j) => CardProgress(
        box: (j['b'] as num?)?.toInt() ?? 0,
        due: (j['d'] as num?)?.toInt() ?? 0,
        rightDays: ((j['r'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );
}

/// Everything saved on the phone: settings, card progress, daily counts and
/// where the player stopped. Content (the decks) is never stored here.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  /// Waits after each "Got it": box 1 → 10 min, box 2 → 1 day, and so on.
  static const List<Duration> intervals = [
    Duration(minutes: 10),
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 21),
  ];

  static const int masteryDays = 3;

  SharedPreferences? _prefs;

  /// Set when saved data could not be loaded; the app still runs without it.
  String? initError;
  ThemeMode themeMode = ThemeMode.system;
  final Map<String, CardProgress> _progress = {};
  final Map<String, int> _daily = {};
  final Map<String, int> _totals = {};
  String? resumeSetKey;
  String? resumeCardId;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 8));
      _prefs = prefs;
      themeMode = switch (prefs.getString('theme')) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      _readJson('progress').forEach((k, v) {
        if (v is Map) _progress[k] = CardProgress.fromJson(Map<String, dynamic>.from(v));
      });
      _readJson('daily').forEach((k, v) {
        if (v is num) _daily[k] = v.toInt();
      });
      _readJson('totals').forEach((k, v) {
        if (v is num) _totals[k] = v.toInt();
      });
      resumeSetKey = prefs.getString('resume_set');
      resumeCardId = prefs.getString('resume_card');
    } catch (e) {
      initError = 'Saved data could not be loaded: $e';
    }
    notifyListeners();
  }

  Map<String, dynamic> _readJson(String key) {
    final s = _prefs?.getString(key);
    if (s == null) return {};
    try {
      final v = jsonDecode(s);
      return v is Map ? Map<String, dynamic>.from(v) : {};
    } catch (_) {
      return {};
    }
  }

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---- Settings ----

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    await _prefs?.setString('theme', switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  // ---- Daily counts and streak ----

  int get todayFlips => _daily[dayKey(DateTime.now())] ?? 0;

  int totalFlips(String deck) => _totals[deck] ?? 0;

  /// Days in a row with at least one flip. Today still counts as "kept"
  /// until midnight, so the streak shows yesterday's run if today is empty.
  int get streak {
    var d = DateTime.now();
    if ((_daily[dayKey(d)] ?? 0) == 0) d = DateTime(d.year, d.month, d.day - 1);
    var n = 0;
    while ((_daily[dayKey(d)] ?? 0) > 0) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }

  Future<void> recordFlip(KanaCard card) async {
    final today = dayKey(DateTime.now());
    _daily[today] = (_daily[today] ?? 0) + 1;
    _totals[card.deck] = (_totals[card.deck] ?? 0) + 1;
    notifyListeners();
    await _prefs?.setString('daily', jsonEncode(_daily));
    await _prefs?.setString('totals', jsonEncode(_totals));
  }

  // ---- Spaced repetition ----

  CardProgress? progressOf(String id) => _progress[id];

  int masteryOf(String id) => math.min(_progress[id]?.rightDays.length ?? 0, masteryDays);

  Future<void> answer(KanaCard card, Answer a) async {
    final p = _progress.putIfAbsent(card.id, CardProgress.new);
    final now = DateTime.now();
    if (a == Answer.again) {
      p.box = 0;
      p.due = now.millisecondsSinceEpoch;
    } else {
      p.box = math.min(p.box + 1, intervals.length);
      p.due = now.add(intervals[p.box - 1]).millisecondsSinceEpoch;
      final today = dayKey(now);
      if (!p.rightDays.contains(today)) {
        p.rightDays.add(today);
        if (p.rightDays.length > masteryDays) p.rightDays.removeAt(0);
      }
    }
    notifyListeners();
    await _prefs?.setString('progress', jsonEncode(_progress.map((k, v) => MapEntry(k, v.toJson()))));
  }

  // ---- Resume where the player stopped ----

  Future<void> saveResume(PracticeSet set, KanaCard card) async {
    resumeSetKey = set.key;
    resumeCardId = card.id;
    await _prefs?.setString('resume_set', set.key);
    await _prefs?.setString('resume_card', card.id);
  }
}
