import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Glass (dark) tokens ──────────────────────────────────────────────────
  static const Color glassBg        = Color(0xFF07080B);
  static const Color glassBg2       = Color(0xFF0C0E14);
  static const Color glassSurface   = Color(0x0DFFFFFF); // ~5%
  static const Color glassSurface2  = Color(0x14FFFFFF); // ~8%
  static const Color glassBorder    = Color(0x1AFFFFFF); // ~10%
  static const Color glassBorder2   = Color(0x2BFFFFFF); // ~17%
  static const Color glassInk       = Color(0xFFF8F9FB);
  static const Color glassInk2      = Color(0xFFC5C7D0);
  static const Color glassMuted     = Color(0xFF7A7D8A);
  static const Color glassAccent    = Color(0xFF4DB6FF); // oklch(75% 0.16 235)
  static const Color glassAccent2   = Color(0xFF63D9FF); // oklch(82% 0.14 215)
  static const Color glassAccentGlow = Color(0x664DB6FF); // 40% glow

  // ── Paper (light) tokens ─────────────────────────────────────────────────
  static const Color paperBg        = Color(0xFFF9F6F0); // Warmer, creamier
  static const Color paperSurface   = Color(0xFFFEFDFC); // Near-white paper
  static const Color paperInk       = Color(0xFF1A1714); // Deep charcoal ink
  static const Color paperInk2      = Color(0xFF423D38); // Medium ink
  static const Color paperMuted     = Color(0xFF8B8477); // Faded ink
  static const Color paperFaint     = Color(0xFFE8E2D5);
  static const Color paperLine      = Color(0xFFF0EAE0); // Very soft rule lines
  static const Color paperAccent    = Color(0xFFCD6924); // oklch(58% 0.18 45) - Burnt Orange
  static const Color paperAccentSoft = Color(0xFFF7ECE1);
  static const Color paperAccentInk = Color(0xFF7A3E16);

  // ── Semantic aliases (used by widgets that don't know which theme is active)
  static const Color _accentPink    = Color(0xFFFF2D55);
  static const Color _accentGreen   = Color(0xFF34C759);
  static const Color _accentOrange  = Color(0xFFFF9500);

  // Legacy getters — kept so existing references compile without changes
  static Color get primaryBlue  => glassAccent;
  static Color get accentPurple => const Color(0xFF5E5CE6);
  static Color get accentPink   => _accentPink;
  static Color get accentOrange => _accentOrange;
  static Color get accentGreen  => _accentGreen;

  // ── Text theme ───────────────────────────────────────────────────────────
  // Fraunces → display / headline (editorial serif)
  // Inter     → title / body / label (clean sans)
  static TextTheme _buildTextTheme(Color displayColor, Color bodyColor) {
    return TextTheme(
      displayLarge:  GoogleFonts.fraunces(fontSize: 57, fontWeight: FontWeight.w600, color: displayColor),
      displayMedium: GoogleFonts.fraunces(fontSize: 45, fontWeight: FontWeight.w600, color: displayColor),
      displaySmall:  GoogleFonts.fraunces(fontSize: 36, fontWeight: FontWeight.w500, color: displayColor),
      headlineLarge:  GoogleFonts.fraunces(fontSize: 32, fontWeight: FontWeight.w600, color: displayColor),
      headlineMedium: GoogleFonts.fraunces(fontSize: 28, fontWeight: FontWeight.w500, color: displayColor),
      headlineSmall:  GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w500, color: displayColor),
      titleLarge:  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: bodyColor),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: bodyColor),
      titleSmall:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: bodyColor),
      bodyLarge:   GoogleFonts.inter(fontSize: 16, color: bodyColor),
      bodyMedium:  GoogleFonts.inter(fontSize: 14, color: bodyColor),
      bodySmall:   GoogleFonts.inter(fontSize: 12, color: bodyColor),
      labelLarge:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: bodyColor),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: bodyColor),
      labelSmall:  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: bodyColor),
    );
  }

  // ── Light theme — Paper ───────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: paperAccent,
    scaffoldBackgroundColor: paperBg,
    colorScheme: const ColorScheme.light(
      primary: paperAccent,
      secondary: paperAccentInk,
      surface: paperSurface,
      surfaceVariant: paperBg,
      error: _accentPink,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: paperInk,
      onError: Colors.white,
    ),
    textTheme: _buildTextTheme(paperInk, paperInk),
    appBarTheme: AppBarTheme(
      backgroundColor: paperBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: paperAccent),
      titleTextStyle: GoogleFonts.fraunces(
        fontSize: 24, fontWeight: FontWeight.w500, color: paperInk,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: paperAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    cardTheme: const CardTheme(
      color: paperSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: paperSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: paperLine),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: paperLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: paperAccent, width: 2),
      ),
      hintStyle: const TextStyle(color: paperMuted),
    ),
    dividerColor: paperLine,
    hintColor: paperMuted,
  );

  // ── Dark theme — Glass ────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: glassAccent,
    scaffoldBackgroundColor: glassBg,
    colorScheme: const ColorScheme.dark(
      primary: glassAccent,
      secondary: glassAccent2,
      surface: Color(0xFF0E1016),   // glassBg2
      surfaceVariant: Color(0x14FFFFFF), // glassBorder
      error: _accentPink,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: glassInk,
      onError: Colors.white,
    ),
    textTheme: _buildTextTheme(glassInk, glassInk),
    appBarTheme: AppBarTheme(
      backgroundColor: glassBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: glassAccent),
      titleTextStyle: GoogleFonts.fraunces(
        fontSize: 24, fontWeight: FontWeight.w500, color: glassInk,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: glassAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        shadowColor: glassAccentGlow,
      ),
    ),
    cardTheme: const CardTheme(
      color: Color(0x0AFFFFFF), // glassSurface
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x0AFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: glassAccent, width: 2),
      ),
      hintStyle: const TextStyle(color: glassMuted),
      labelStyle: const TextStyle(color: glassInk2),
    ),
    dividerColor: const Color(0x14FFFFFF),
    hintColor: glassMuted,
  );
}

// ── Typography helpers ────────────────────────────────────────────────────────
// Fraunces  → editorial display / subject headings
// JetBrains Mono → time stamps, badges, status labels
// Inter     → body, mentor names, supporting text
class AppTextStyles {
  // Fraunces — large headings and subject names
  static TextStyle get interTitle => GoogleFonts.fraunces(
    fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5,
  );
  static TextStyle get interSubject => GoogleFonts.fraunces(
    fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: -0.3,
  );
  static TextStyle get interNext => GoogleFonts.fraunces(
    fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.2,
  );

  // Inter — body and supporting text
  static TextStyle get interSubtitle => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2,
  );
  static TextStyle get interProgress => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static TextStyle get interMentor => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static TextStyle get interSmall => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.1,
  );

  // JetBrains Mono — times, badges, status chips
  static TextStyle get monoLabel => GoogleFonts.jetBrainsMono(
    fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.4,
  );
  static TextStyle get interLiveNow => GoogleFonts.jetBrainsMono(
    fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2,
  );
  static TextStyle get interBadge => GoogleFonts.jetBrainsMono(
    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3,
  );
}
