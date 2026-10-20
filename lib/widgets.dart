import 'package:flutter/material.dart';

import 'services/speech.dart';
import 'theme.dart';

/// Rounded square button with a speaker icon. Tap plays, long-press plays slowly.
class SpeakButton extends StatelessWidget {
  const SpeakButton({
    super.key,
    required this.text,
    this.reading,
    required this.background,
    required this.foreground,
    this.size = 44,
    this.label = 'Play sound',
  });

  final String text;
  final String? reading;
  final Color background;
  final Color foreground;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label. Hold for slow',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Speech.speak(text, reading: reading),
          onLongPress: () => Speech.speak(text, reading: reading, slow: true),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(Icons.volume_up_rounded, color: foreground, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}

/// The square back button used at the top of inner screens.
class BackSquare extends StatelessWidget {
  const BackSquare({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).maybePop(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.chevron_left_rounded, color: c.text, size: 28),
          ),
        ),
      ),
    );
  }
}

/// White rounded panel with a thin border.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
      ),
      child: child,
    );
  }
}

/// Small grey section heading like "APPEARANCE".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: context.c.muted),
      ),
    );
  }
}
