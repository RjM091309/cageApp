import 'package:flutter/material.dart';

// --- sample.html / Premium Dashboard color pattern ---
// Background gradient: #0f0f1a → #1a1a2e → #16213e
// Primary gradient: #6366f1 (indigo) → #a855f7 (purple)
// Accent highlight: #a78bfa

final Color surfaceDarkStart = const Color(0xFF0F0F1A);
final Color surfaceDarkMid = const Color(0xFF1A1A2E);
final Color surfaceDarkEnd = const Color(0xFF16213E);

final appBarBackground = surfaceDarkStart;
final surfaceColor = surfaceDarkStart;
final cardBg = Colors.white.withValues(alpha: 0.03);
final borderColor = Colors.white.withValues(alpha: 0.06);
final borderColorSubtle = Colors.white.withValues(alpha: 0.08);

// Primary gradient colors (indigo → purple)
final primaryIndigo = const Color(0xFF6366F1);
final primaryPurple = const Color(0xFFA855F7);
final accentPurple = const Color(0xFFA78BFA);

// Semantic (keep for win/loss/alert)
final emeraldAccent = const Color(0xFF10B981);
final roseAccent = const Color(0xFFF43F5E);
final amberAccent = const Color(0xFFF59E0B);
/// Teal accent (e.g. distinct from other stat cards)
final tealAccent = const Color(0xFF14B8A6);
/// Brown accent (e.g. House Balance card)
final brownAccent = const Color(0xFFB45309);

/// Gradient for primary actions, active states, progress (like sample.html)
LinearGradient get primaryGradient => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
    );

/// Background gradient for scaffold (sample.html body)
LinearGradient get scaffoldGradient => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.5, 1.0],
      colors: [
        Color(0xFF0F0F1A),
        Color(0xFF1A1A2E),
        Color(0xFF16213E),
      ],
    );

ThemeData get appTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surfaceColor,
    colorScheme: ColorScheme.dark(
      primary: primaryIndigo,
      secondary: primaryPurple,
      surface: surfaceColor,
      error: roseAccent,
      onSurface: Colors.white,
      onPrimary: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: appBarBackground,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: appBarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
      ),
    ),
  );
}
