import 'package:flutter/material.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../services/decks.dart';
import '../theme.dart';
import '../widgets.dart';
import 'flip_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, PracticeSet set, {int? limit, bool resume = false}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FlipScreen(set: set, limit: limit, resume: resume),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppState.instance;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final resumeSet = PracticeSet.byKey(state.resumeSetKey);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('おかえり · Welcome back', style: TextStyle(fontSize: 13, color: c.muted)),
                          const SizedBox(height: 2),
                          const Text("Let's practice", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    _StreakPill(days: state.streak),
                    const SizedBox(width: 8),
                    Material(
                      color: c.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: c.line),
                      ),
                      child: IconButton(
                        tooltip: 'Settings',
                        icon: Icon(Icons.settings_outlined, color: c.text),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.initError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: c.redSoft, borderRadius: BorderRadius.circular(14)),
                    child: SelectableText(
                      '${state.initError}\nProgress will not be saved until this is fixed.',
                      style: TextStyle(fontSize: 12, color: c.redText),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ContinueCard(
                        set: resumeSet,
                        cardId: state.resumeCardId,
                        onTap: () => _open(context, resumeSet ?? PracticeSet.hiragana, resume: resumeSet != null),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _QuickFive(onTap: () => _open(context, resumeSet ?? PracticeSet.hiragana, limit: 5)),
                  ],
                ),
                const SizedBox(height: 16),
                Panel(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Flips today', style: TextStyle(fontSize: 12, color: c.muted)),
                            Text('${state.todayFlips}',
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2)),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'Flip at least one card a day to keep your streak',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 12, color: c.muted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Practice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _DeckTile(
                  glyph: 'あ',
                  title: 'Hiragana',
                  sub: '46 basic + dakuten + combos',
                  bg: c.redSoft,
                  fg: c.redText,
                  onTap: () => _open(context, PracticeSet.hiragana),
                ),
                _DeckTile(
                  glyph: 'ア',
                  title: 'Katakana',
                  sub: '46 basic + dakuten + combos',
                  bg: c.blueSoft,
                  fg: c.blue,
                  onTap: () => _open(context, PracticeSet.katakana),
                ),
                _DeckTile(
                  glyph: 'あア',
                  title: 'Hiragana + Katakana',
                  sub: 'Both scripts mixed together',
                  bg: c.purpleSoft,
                  fg: c.purple,
                  onTap: () => _open(context, PracticeSet.both),
                ),
                const SizedBox(height: 20),
                const Text('Coming soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                for (final s in const [
                  ('カ', 'Katakana words', 'コーヒー, ビール, タクシー…'),
                  ('漢', 'Kanji', 'By JLPT level or topic'),
                  ('食', 'Food menu', 'Dishes and menu words'),
                  ('駅', 'Train station', 'Exits, gates, platforms, tickets'),
                  ('口', 'Signs & shops', 'Toilets, doors, open or closed'),
                ])
                  _DeckTile(glyph: s.$1, title: s.$2, sub: s.$3, bg: c.track, fg: c.muted, onTap: null),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      label: '$days day streak',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_outlined, size: 18, color: c.red),
            const SizedBox(width: 4),
            Text('$days', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.set, required this.cardId, required this.onTap});

  final PracticeSet? set;
  final String? cardId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = set;
    return Material(
      color: c.inverse,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c.red, borderRadius: BorderRadius.circular(14)),
                child: s == null
                    ? Text('あ', style: TextStyle(fontFamily: kanaFont, fontSize: 26, color: c.onAccent))
                    : FutureBuilder<String?>(
                        future: _frontOf(s, cardId),
                        builder: (context, snap) => Text(
                          snap.data ?? '',
                          style: TextStyle(fontFamily: kanaFont, fontSize: 22, color: c.onAccent),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s == null ? 'Start here' : 'Where you left off',
                        style: TextStyle(fontSize: 12, color: c.onInverseMuted)),
                    Text(
                      s == null ? 'Hiragana' : 'Continue ${s.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.onInverse),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<String?> _frontOf(PracticeSet set, String? id) async {
    final cards = await Decks.loadSet(set);
    for (final card in cards) {
      if (card.id == id) return card.front;
    }
    return cards.isEmpty ? null : cards.first.front;
  }
}

class _QuickFive extends StatelessWidget {
  const _QuickFive({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: c.text, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          width: 92,
          height: 76,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, color: c.red),
              const Text('Quick 5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text('~1 min', style: TextStyle(fontSize: 11, color: c.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.glyph,
    required this.title,
    required this.sub,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final String glyph;
  final String title;
  final String sub;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: c.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                  child: Text(glyph, style: TextStyle(fontFamily: kanaFont, fontSize: glyph.length > 1 ? 20 : 24, color: fg)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: enabled ? c.text : c.muted)),
                      const SizedBox(height: 2),
                      Text(sub, style: TextStyle(fontSize: 12, color: c.muted)),
                    ],
                  ),
                ),
                if (enabled)
                  Icon(Icons.chevron_right_rounded, color: c.muted)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.track, borderRadius: BorderRadius.circular(999)),
                    child: Text('Soon', style: TextStyle(fontSize: 11, color: c.muted, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
