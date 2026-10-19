import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kana_cards/models.dart';

void main() {
  test('highlights the card kana inside an example word', () {
    expect(splitHighlight('おかね', 'ね'), ('おか', 'ね', ''));
    expect(splitHighlight('でんしゃ', 'しゃ'), ('でん', 'しゃ', ''));
    expect(splitHighlight('ねこ', 'x'), ('ねこ', '', ''));
  });

  for (final deck in ['hiragana', 'katakana']) {
    test('$deck deck loads with unique ids', () {
      final data = jsonDecode(File('assets/decks/$deck.json').readAsStringSync()) as Map;
      final cards = (data['cards'] as List)
          .map((e) => KanaCard.fromJson(deck, Map<String, dynamic>.from(e as Map)))
          .toList();
      expect(cards.length, 104);
      expect(cards.map((c) => c.id).toSet().length, cards.length);
      for (final c in cards) {
        for (final e in c.examples) {
          expect(e.word.contains(c.front), isTrue, reason: '${c.front} missing from ${e.word}');
        }
      }
    });
  }
}
