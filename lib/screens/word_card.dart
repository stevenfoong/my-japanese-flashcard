import 'package:flutter/material.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Look of a word deck's card: a café chalkboard or a restaurant menu.
class _CardLook {
  const _CardLook({
    required this.label,
    required this.bg,
    required this.border,
    required this.text,
    required this.soft,
    required this.accent,
    required this.tip,
  });

  final String label;
  final Color bg;
  final Color border;
  final Color text;
  final Color soft;
  final Color accent;
  final Color tip;

  static const cafe = _CardLook(
    label: 'カタカナ · KATAKANA',
    bg: Color(0xFF26302A),
    border: Color(0xFF4A5A4F),
    text: Color(0xFFFFFFFF),
    soft: Color(0xFFB9C9BC),
    accent: Color(0xFFF2C48D),
    tip: Color(0xFF33403A),
  );

  static const menu = _CardLook(
    label: 'お品書き · MENU',
    bg: Color(0xFF2A211B),
    border: Color(0xFF6B5644),
    text: Color(0xFFFFFFFF),
    soft: Color(0xFFCDBBA2),
    accent: Color(0xFFF2A65A),
    tip: Color(0xFF3A2E25),
  );

  static _CardLook of(KanaCard card) => card.deck == 'food_menu' ? menu : cafe;
}

/// Flip card for word decks. Front: the word as written. Back: reading,
/// romaji with speaker, meaning and a tip. Tapping the card flips it, and
/// on the back counts as Got it.
class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.card, required this.flipped, required this.onTap});

  final KanaCard card;
  final bool flipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final look = _CardLook.of(card);
    return Semantics(
      button: true,
      label: flipped ? '${card.front}, ${card.romaji}, ${card.meaning}. Tap for Got it' : '${card.front}. Tap to reveal',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: look.bg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 12))],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: look.border, width: 1.5),
            ),
            child: Column(
              children: [
                Text(look.label, style: TextStyle(fontSize: 12, letterSpacing: 4, color: look.soft)),
                Expanded(child: flipped ? _back(look) : _front(look)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _front(_CardLook look) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            card.front,
            maxLines: 1,
            style: TextStyle(fontFamily: kanaFont, fontSize: 76, height: 1.2, color: look.text),
          ),
        ),
        const SizedBox(height: 14),
        Text('Read it out loud, then tap', style: TextStyle(fontSize: 14, color: look.soft)),
      ],
    );
  }

  Widget _back(_CardLook look) {
    final mastery = AppState.instance.masteryOf(card.id);
    final showKana = card.kana.isNotEmpty && card.kana != card.front;
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: box.maxHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(card.front, maxLines: 1, style: TextStyle(fontFamily: kanaFont, fontSize: 40, color: look.soft)),
            ),
            if (showKana)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(card.kana, maxLines: 1, style: TextStyle(fontFamily: kanaFont, fontSize: 28, color: look.text)),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    card.romaji,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: look.accent, height: 1.15),
                  ),
                ),
                const SizedBox(width: 12),
                SpeakButton(
                  text: card.front,
                  reading: card.reading,
                  background: look.accent,
                  foreground: look.bg,
                  label: 'Play ${card.romaji}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(card.meaning, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: look.text)),
            if (card.note.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: look.tip, borderRadius: BorderRadius.circular(12)),
                child: Text(card.note, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: look.soft)),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < AppState.masteryDays; i++)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < mastery ? look.accent : Colors.transparent,
                      border: Border.all(color: i < mastery ? look.accent : look.border, width: 2),
                    ),
                  ),
                const SizedBox(width: 6),
                Text(
                  mastery >= AppState.masteryDays ? 'Mastered' : 'Tap card = Got it',
                  style: TextStyle(fontSize: 12, color: look.soft),
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
