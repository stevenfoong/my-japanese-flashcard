import 'dart:convert';

import 'package:flutter/services.dart';

import '../models.dart';

/// Loads deck files from assets/decks/<name>.json, once per app run.
class Decks {
  static final Map<String, List<KanaCard>> _cache = {};

  static Future<List<KanaCard>> load(String deck) async {
    final cached = _cache[deck];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/decks/$deck.json');
    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final cards = (data['cards'] as List)
        .map((e) => KanaCard.fromJson(deck, Map<String, dynamic>.from(e as Map)))
        .toList();
    _cache[deck] = cards;
    return cards;
  }

  static Future<List<KanaCard>> loadSet(PracticeSet set) async {
    final lists = await Future.wait(set.decks.map(load));
    return [for (final l in lists) ...l];
  }
}
