import 'package:flutter/material.dart';

/// Every colour the app uses. Screens read these through `context.c`
/// so light and dark mode switch in one place.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.card,
    required this.line,
    required this.text,
    required this.muted,
    required this.track,
    required this.red,
    required this.redSoft,
    required this.redText,
    required this.blue,
    required this.blueSoft,
    required this.green,
    required this.greenSoft,
    required this.amber,
    required this.amberSoft,
    required this.purple,
    required this.purpleSoft,
    required this.inverse,
    required this.onInverse,
    required this.onInverseMuted,
    required this.onAccent,
  });

  final Color bg;
  final Color card;
  final Color line;
  final Color text;
  final Color muted;
  final Color track;
  final Color red;
  final Color redSoft;
  final Color redText;
  final Color blue;
  final Color blueSoft;
  final Color green;
  final Color greenSoft;
  final Color amber;
  final Color amberSoft;
  final Color purple;
  final Color purpleSoft;
  final Color inverse;
  final Color onInverse;
  final Color onInverseMuted;

  /// Text or icon colour on a filled red / green / blue / amber button.
  final Color onAccent;

  static const light = AppColors(
    bg: Color(0xFFF5F3EF),
    card: Color(0xFFFFFFFF),
    line: Color(0xFFE3DFD6),
    text: Color(0xFF1B1E27),
    muted: Color(0xFF5B6070),
    track: Color(0xFFE6E1D8),
    red: Color(0xFFC8372D),
    redSoft: Color(0xFFFBE6E3),
    redText: Color(0xFFA82C23),
    blue: Color(0xFF2B4C7E),
    blueSoft: Color(0xFFE2E9F4),
    green: Color(0xFF2F6B4F),
    greenSoft: Color(0xFFE1EEE7),
    amber: Color(0xFF8A4B00),
    amberSoft: Color(0xFFFDF1E3),
    purple: Color(0xFF5B3F85),
    purpleSoft: Color(0xFFECE6F3),
    inverse: Color(0xFF1B1E27),
    onInverse: Color(0xFFFFFFFF),
    onInverseMuted: Color(0xFFC9CCD6),
    onAccent: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    bg: Color(0xFF121318),
    card: Color(0xFF1D1F27),
    line: Color(0xFF2C2F3A),
    text: Color(0xFFEDEBE6),
    muted: Color(0xFFA3A7B4),
    track: Color(0xFF262934),
    red: Color(0xFFE5604F),
    redSoft: Color(0xFF3A2224),
    redText: Color(0xFFF08A7C),
    blue: Color(0xFF8FB0E3),
    blueSoft: Color(0xFF1F2A3D),
    green: Color(0xFF6FBF95),
    greenSoft: Color(0xFF1C2E25),
    amber: Color(0xFFF2A65A),
    amberSoft: Color(0xFF33271A),
    purple: Color(0xFFB9A3E0),
    purpleSoft: Color(0xFF2A2338),
    inverse: Color(0xFF2A2D38),
    onInverse: Color(0xFFFFFFFF),
    onInverseMuted: Color(0xFFA3A7B4),
    onAccent: Color(0xFF121318),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is AppColors && t >= 0.5) return other;
    return this;
  }
}

extension AppColorsContext on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}

/// Font used for the big kana on the cards.
const String kanaFont = 'KleeOne';

ThemeData buildTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: colors.red,
    onPrimary: colors.onAccent,
    secondary: colors.blue,
    onSecondary: colors.onAccent,
    error: colors.red,
    onError: colors.onAccent,
    surface: colors.card,
    onSurface: colors.text,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.bg,
    fontFamily: 'MPlusRounded',
    dividerColor: colors.line,
    extensions: [colors],
  );
}
