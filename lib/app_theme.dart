import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Glass (dark) tokens ──────────────────────────────────────────────────
  static const Color glassBg        = Color(0xFF08090D);
  static const Color glassBg2       = Color(0xFF0E1016);
  static const Color glassSurface   = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)
  static const Color glassSurface2  = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const Color glassBorder    = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color glassBorder2   = Color(0x24FFFFFF); // rgba(255,255,255,0.14)
  static const Color glassInk       = Color(0xFFF4F5F7);
  static const Color glassInk2      = Color(0xFFB8BAC2);
  static const Color glassMuted     = Color(0xFF6C6F79);
  static const Color glassAccent    = Color(0xFF3BA9FF); // oklch(72% 0.18 230)
  static const Color glassAccent2   = Color(0xFF4FD1FF); // oklch(78% 0.22 210)
  static const Color glassAccentGlow = Color(0x803BA9FF); // accent / 50%

  // ── Paper (light) tokens ─────────────────────────────────────────────────
  static const Color paperBg        = Color(0xFFF6F2EA);
  static const Color paperSurface   = Color(0xFFFBF8F1);
  static const Color paperInk       = Color(0xFF15130F);
  static const Color paperInk2      = Color(0xFF3C382F);
  static const Color paperMuted     = Color(0xFF7D7668);
  static const Color paperFaint     = Color(0xFFD9D2C2);
  static const Color paperLine      = Color(0xFFE7E1D2);
  static const Color paperAccent    = Color(0xFFD97D3A); // oklch(62% 0.18 48)
  static const Color paperAccentSoft = Color(0xFFF3E9DD);
  static const Color paperAccentInk = Color(0xFF6E3510);

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
  static const TextTheme _textTheme = TextTheme(
    displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    headlineSmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge:   TextStyle(fontSize: 16),
    bodyMedium:  TextStyle(fontSize: 14),
    bodySmall:   TextStyle(fontSize: 12),
    labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );

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
    textTheme: _textTheme.apply(displayColor: paperInk, bodyColor: paperInk),
    appBarTheme: AppBarTheme(
      backgroundColor: paperBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: paperAccent),
      titleTextStyle: _textTheme.headlineSmall?.copyWith(
        color: paperInk, fontWeight: FontWeight.bold,
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
    textTheme: _textTheme.apply(displayColor: glassInk, bodyColor: glassInk),
    appBarTheme: AppBarTheme(
      backgroundColor: glassBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: glassAccent),
      titleTextStyle: _textTheme.headlineSmall?.copyWith(
        color: glassInk, fontWeight: FontWeight.bold,
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
class AppTextStyles {
  static TextStyle get interTitle => const TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5,
  );
  static TextStyle get interSubtitle => const TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2,
  );
  static TextStyle get interBadge => const TextStyle(
    fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.3,
  );
  static TextStyle get interLiveNow => const TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2,
  );
  static TextStyle get interSubject => const TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3,
  );
  static TextStyle get interProgress => const TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static TextStyle get interMentor => const TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static TextStyle get interNext => const TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2,
  );
  static TextStyle get interSmall => const TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.1,
  );
  // Mono label style — mirrors JetBrains Mono usage in the design
  static TextStyle get monoLabel => const TextStyle(
    fontSize: 10, fontWeight: FontWeight.w500,
    letterSpacing: 1.4,
  );
}
