import 'package:flutter/material.dart';

@immutable
class AppPalette {
  const AppPalette({
    required this.seed,
    required this.scaffold,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.accentWarm,
    required this.border,
    required this.badgeIdle,
    required this.badgeIdleBorder,
    required this.heroStart,
    required this.heroEnd,
    required this.panelStart,
    required this.panelEnd,
    required this.tileStart,
    required this.tileEnd,
    required this.tileAltStart,
    required this.tileAltEnd,
    required this.appIconFallback,
    required this.success,
    required this.shadow,
  });

  final Color seed;
  final Color scaffold;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSoft;
  final Color accentWarm;
  final Color border;
  final Color badgeIdle;
  final Color badgeIdleBorder;
  final Color heroStart;
  final Color heroEnd;
  final Color panelStart;
  final Color panelEnd;
  final Color tileStart;
  final Color tileEnd;
  final Color tileAltStart;
  final Color tileAltEnd;
  final Color appIconFallback;
  final Color success;
  final Color shadow;
}

class AppColors {
  static const AppPalette light = AppPalette(
    seed: Color(0xFF0E7490),
    scaffold: Color(0xFFF4F7FB),
    surface: Colors.white,
    surfaceAlt: Color(0xFFF0F4F8),
    surfaceStrong: Color(0xFFDCE7EF),
    textPrimary: Color(0xFF16202A),
    textSecondary: Color(0xFF536271),
    textMuted: Color(0xFF788796),
    accent: Color(0xFF2B7FFF),
    accentSoft: Color(0x1F2B7FFF),
    accentWarm: Color(0xFF62B0FF),
    border: Color(0xFFD7E1EA),
    badgeIdle: Color(0xFFE3EAF1),
    badgeIdleBorder: Color(0xFFB8C4D0),
    heroStart: Color(0xFFE8F0F8),
    heroEnd: Color(0xFFDCE6F1),
    panelStart: Color(0xFFF8FBFD),
    panelEnd: Color(0xFFEEF3F8),
    tileStart: Color(0xFFFFFFFF),
    tileEnd: Color(0xFFF5F8FB),
    tileAltStart: Color(0xFFF8FAFD),
    tileAltEnd: Color(0xFFEEF2F7),
    appIconFallback: Color(0xFF2094F3),
    success: Color(0xFF2EA56B),
    shadow: Color(0x14000000),
  );

  static const AppPalette dark = AppPalette(
    seed: Color(0xFF67E8F9),
    scaffold: Color(0xFF2E2D37),
    surface: Color(0xFF3A3943),
    surfaceAlt: Color(0xFF383742),
    surfaceStrong: Color(0xFF4B4A57),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFCAC8D4),
    textMuted: Color(0xFF9C9BA6),
    accent: Color(0xFF5CA9FF),
    accentSoft: Color(0x225CA9FF),
    accentWarm: Color(0xFF8AC5FF),
    border: Color(0xFF454351),
    badgeIdle: Color(0xFF45424F),
    badgeIdleBorder: Color(0xFF696776),
    heroStart: Color(0xFF423F51),
    heroEnd: Color(0xFF2F2E39),
    panelStart: Color(0xFF3C3A47),
    panelEnd: Color(0xFF343340),
    tileStart: Color(0xFF373542),
    tileEnd: Color(0xFF302F39),
    tileAltStart: Color(0xFF3D3B47),
    tileAltEnd: Color(0xFF34333E),
    appIconFallback: Color(0xFF2094F3),
    success: Color(0xFF3DDC84),
    shadow: Color(0x22000000),
  );

  static AppPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
