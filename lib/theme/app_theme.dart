import 'package:flutter/material.dart';

final appBarBackground = const Color(0xFF01081A);
final surfaceColor = const Color(0xFF01081A);
final cardBg = Colors.white.withValues(alpha: 0.05);
final borderColor = Colors.white.withValues(alpha: 0.1);
final cyanAccent = const Color(0xFF06B6D4);
final emeraldAccent = const Color(0xFF10B981);
final roseAccent = const Color(0xFFF43F5E);
final amberAccent = const Color(0xFFF59E0B);

ThemeData get appTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surfaceColor,
    colorScheme: ColorScheme.dark(
      primary: cyanAccent,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: appBarBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(0))),
    ),
  );
}
