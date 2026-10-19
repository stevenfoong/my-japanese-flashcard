/// One example word on the back of a card, e.g. ねこ / neko / cat.
class Example {
  const Example({required this.word, required this.romaji, required this.meaning});

  final String word;
  final String romaji;
  final String meaning;

  factory Example.fromJson(Map<String, dynamic> j) => Example(
        word: j['word'] as String,
        romaji: j['romaji'] as String,
        meaning: j['meaning'] as String,
      );
}

/// One flash card, loaded from a deck file in assets/decks/.
class KanaCard {
  const KanaCard({
    required this.id,
    required this.deck,
    required this.front,
    required this.romaji,
    required this.group,
    required this.partner,
    required this.lookAlike,
    required this.note,
    required this.audio,
    required this.examples,
  });

  final String id;
  final String deck;
  final String front;
  final String romaji;
  final String group;
  final String partner;
  final List<String> lookAlike;
  final String note;
  final String? audio;
  final List<Example> examples;

  factory KanaCard.fromJson(String deck, Map<String, dynamic> j) => KanaCard(
        id: j['id'] as String,
        deck: deck,
        front: j['front'] as String,
        romaji: j['romaji'] as String,
        group: (j['group'] as String?) ?? 'basic',
        partner: (j['partner'] as String?) ?? '',
        lookAlike: ((j['look_alike'] as List?) ?? const []).map((e) => e.toString()).toList(),
        note: (j['note'] as String?) ?? '',
        audio: j['audio'] as String?,
        examples: ((j['examples'] as List?) ?? const [])
            .map((e) => Example.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

/// A choice on the home screen: which decks go into the practice session.
class PracticeSet {
  const PracticeSet(this.key, this.title, this.decks);

  final String key;
  final String title;
  final List<String> decks;

  static const hiragana = PracticeSet('hiragana', 'Hiragana', ['hiragana']);
  static const katakana = PracticeSet('katakana', 'Katakana', ['katakana']);
  static const both = PracticeSet('hiragana+katakana', 'Hiragana + Katakana', ['hiragana', 'katakana']);

  static const all = [hiragana, katakana, both];

  static PracticeSet? byKey(String? key) {
    for (final s in all) {
      if (s.key == key) return s;
    }
    return null;
  }
}

/// Splits [word] around the first [part] so the card's kana can be highlighted.
/// Returns (before, match, after); match is empty when [part] is not found.
(String, String, String) splitHighlight(String word, String part) {
  final i = part.isEmpty ? -1 : word.indexOf(part);
  if (i < 0) return (word, '', '');
  return (word.substring(0, i), part, word.substring(i + part.length));
}
