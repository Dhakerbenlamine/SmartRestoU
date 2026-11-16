import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _primary = Color(0xFF5B42F5);
  static const _ink = Color(0xFF171B3A);
  static const _muted = Color(0xFF8992B3);
  static const _background = Color(0xFFF2F3F8);

  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: _background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      surface: Colors.white,
      error: const Color(0xFFCC4050),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: _ink,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: _ink,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: _ink,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: _ink),
      bodyMedium: TextStyle(color: _muted),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE0E3EF)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0xFFEAE6FF),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
