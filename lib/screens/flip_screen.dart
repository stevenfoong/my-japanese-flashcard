import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../services/decks.dart';
import '../theme.dart';
import '../widgets.dart';

/// The endless flip-card session. Tap the front to reveal; on the back,
/// Again / Skip / Got it, or tap empty space for Got it.
class FlipScreen extends StatefulWidget {
  const FlipScreen({super.key, required this.set, this.limit, this.resume = false});

  final PracticeSet set;

  /// Stop after this many answers (Quick 5). Null means endless.
  final int? limit;

  /// Start from the card the player stopped on last time.
  final bool resume;

  @override
  State<FlipScreen> createState() => _FlipScreenState();
}

class _FlipScreenState extends State<FlipScreen> {
  final _rng = math.Random();
  final _state = AppState.instance;

  List<KanaCard> _pool = const [];
  final Map<String, KanaCard> _byId = {};

  /// Cards answered "Again": (card id, show again after this many cards).
  final List<(String, int)> _againQueue = [];

  KanaCard? _card;
  String? _error;
  bool _flipped = false;
  int _shown = 0;
  int _answered = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<KanaCard> cards;
    try {
      cards = await Decks.loadSet(widget.set);
    } catch (e) {
      if (mounted) setState(() => _error = 'Cards could not be loaded: $e');
      return;
    }
    if (!mounted) return;
    _pool = cards;
    for (final c in cards) {
      _byId[c.id] = c;
    }
    KanaCard? first;
    if (widget.resume) first = _byId[_state.resumeCardId];
    _show(first ?? _pickNext());
  }

  void _show(KanaCard card) {
    setState(() {
      _card = card;
      _flipped = false;
      _shown++;
    });
    _state.saveResume(widget.set, card);
  }

  KanaCard _pickNext() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final currentId = _card?.id;

    // 1. A card answered "Again" whose short wait is over.
    final ready = _againQueue.indexWhere((e) => e.$2 <= _shown && e.$1 != currentId);
    if (ready >= 0) {
      final card = _byId[_againQueue.removeAt(ready).$1];
      if (card != null) return card;
    }

    final others = _pool.where((c) => c.id != currentId).toList();
    if (others.isEmpty) return _pool.first;
    bool waiting(KanaCard c) => _againQueue.any((e) => e.$1 == c.id);

    // 2. Cards that are due for review.
    final due = others.where((c) {
      final p = _state.progressOf(c.id);
      return p != null && p.due <= now && !waiting(c);
    }).toList();
    if (due.isNotEmpty) return due[_rng.nextInt(due.length)];

    // 3. New cards, mostly in chart order (あいうえお…) so beginners build up.
    final fresh = others.where((c) => _state.progressOf(c.id) == null).toList();
    if (fresh.isNotEmpty) {
      final n = widget.set.decks.length > 1 ? fresh.length : math.min(5, fresh.length);
      return fresh[_rng.nextInt(n)];
    }

    // 4. Everything is learned and not yet due: review the ones due soonest.
    others.sort((a, b) => _state.progressOf(a.id)!.due.compareTo(_state.progressOf(b.id)!.due));
    return others[_rng.nextInt(math.min(8, others.length))];
  }

  void _flip() {
    final card = _card;
    if (card == null || _flipped) return;
    setState(() => _flipped = true);
    _state.recordFlip(card);
  }

  Future<void> _answer(Answer? a) async {
    final card = _card;
    if (card == null) return;
    if (a != null) {
      await _state.answer(card, a);
      if (a == Answer.again) _againQueue.add((card.id, _shown + 4));
      _answered++;
      final limit = widget.limit;
      if (limit != null && _answered >= limit) {
        if (mounted) _finishQuick();
        return;
      }
    }
    if (mounted) _show(_pickNext());
  }

  void _finishQuick() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Nice work!'),
        content: Text('${widget.limit} cards done. Every little session keeps your streak alive.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back home'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _answered = 0);
              _show(_pickNext());
            },
            child: const Text('5 more'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final card = _card;
    final limit = widget.limit;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  const BackSquare(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.set.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(
                          limit == null ? 'Endless · tap Back to stop' : 'Quick $limit · ${math.min(_answered + 1, limit)} of $limit',
                          style: TextStyle(fontSize: 12, color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: _state,
                    builder: (context, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${_state.todayFlips}',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.red)),
                        Text('flips today', style: TextStyle(fontSize: 12, color: c.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: card == null
                    ? Center(
                        child: _error == null
                            ? const CircularProgressIndicator()
                            : SelectableText(_error!, style: TextStyle(color: c.redText)),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(anim), child: child),
                        ),
                        child: _flipped
                            ? _CardBack(key: ValueKey('b${card.id}$_shown'), card: card, onEmptyTap: () => _answer(Answer.gotIt))
                            : _CardFront(key: ValueKey('f${card.id}$_shown'), card: card, onTap: _flip),
                      ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: _BottomButton(
                      label: 'Again',
                      fg: c.redText,
                      bg: c.card,
                      border: c.red,
                      onTap: _flipped ? () => _answer(Answer.again) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 10,
                    child: _BottomButton(
                      label: 'Skip',
                      fg: c.muted,
                      bg: Colors.transparent,
                      border: c.line,
                      onTap: card == null ? null : () => _answer(null),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 13,
                    child: _BottomButton(
                      label: 'Got it',
                      fg: c.onAccent,
                      bg: c.green,
                      border: c.green,
                      onTap: _flipped ? () => _answer(Answer.gotIt) : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.label,
    required this.fg,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  final String label;
  final Color fg;
  final Color bg;
  final Color border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 54,
            child: Center(
              child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({super.key, required this.card, required this.onTap});

  final KanaCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Card ${card.front}. Tap to reveal',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _CardShell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                child: Text(
                  card.front,
                  style: TextStyle(fontFamily: kanaFont, fontSize: card.front.length > 1 ? 130 : 170, height: 1.1),
                ),
              ),
              const SizedBox(height: 12),
              Text('Say it out loud, then tap to reveal', style: TextStyle(fontSize: 14, color: c.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: c.line),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({super.key, required this.card, required this.onEmptyTap});

  final KanaCard card;
  final VoidCallback onEmptyTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final mastery = AppState.instance.masteryOf(card.id);
    final partnerScript = card.deck == 'hiragana' ? 'Katakana' : 'Hiragana';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onEmptyTap,
      child: _CardShell(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(card.front, style: TextStyle(fontFamily: kanaFont, fontSize: card.front.length > 1 ? 64 : 88, height: 1.1)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                card.romaji,
                                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: c.red, height: 1.1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SpeakButton(text: card.front, background: c.red, foreground: c.onAccent, label: 'Play ${card.romaji}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var i = 0; i < AppState.masteryDays; i++)
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i < mastery ? c.green : Colors.transparent,
                                  border: Border.all(color: i < mastery ? c.green : c.line, width: 2),
                                ),
                              ),
                            Flexible(
                              child: Text(
                                mastery >= AppState.masteryDays ? 'Mastered' : '$mastery of ${AppState.masteryDays} days right',
                                style: TextStyle(fontSize: 12, color: c.muted),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (card.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(card.note, style: TextStyle(fontSize: 13, color: c.muted)),
              ],
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoBox(
                      bg: c.blueSoft,
                      fg: c.blue,
                      big: card.partner,
                      title: partnerScript,
                      sub: 'same sound',
                    ),
                  ),
                  if (card.lookAlike.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoBox(
                        bg: c.amberSoft,
                        fg: c.amber,
                        big: card.lookAlike.join(' '),
                        title: "Don't mix up",
                        sub: '',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                  ],
                ],
              ),
              if (card.examples.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'EXAMPLE WORDS · HOLD SPEAKER FOR SLOW',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: c.muted),
                ),
                const SizedBox(height: 4),
                for (final e in card.examples) _ExampleRow(example: e, highlight: card.front),
              ],
              const SizedBox(height: 12),
              Text('Tap empty space = Got it',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: c.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.bg,
    required this.fg,
    required this.big,
    required this.title,
    required this.sub,
    this.icon,
  });

  final Color bg;
  final Color fg;
  final String big;
  final String title;
  final String sub;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
                Text(big, style: TextStyle(fontFamily: kanaFont, fontSize: 24, color: context.c.text)),
                if (sub.isNotEmpty) Text(sub, style: TextStyle(fontSize: 11, color: fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.example, required this.highlight});

  final Example example;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (before, hit, after) = splitHighlight(example.word, highlight);
    final base = TextStyle(fontFamily: kanaFont, fontSize: 24, color: c.text);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
      child: Row(
        children: [
          Flexible(
            flex: 5,
            child: Text.rich(
              TextSpan(style: base, children: [
                TextSpan(text: before),
                TextSpan(text: hit, style: TextStyle(color: c.red, backgroundColor: c.redSoft)),
                TextSpan(text: after),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(example.romaji, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(example.meaning, style: TextStyle(fontSize: 12, color: c.muted)),
              ],
            ),
          ),
          SpeakButton(
            text: example.word,
            background: c.blueSoft,
            foreground: c.blue,
            label: 'Play ${example.romaji}',
          ),
        ],
      ),
    );
  }
}
