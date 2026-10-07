import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LozhkaColors {
  static const bg = Color(0xFFE8EDF2);
  static const bg2 = Color(0xFFDCE3EA);
  static const card = Color(0xFFF6F8FA);
  static const ink = Color(0xFF141922);
  static const ink2 = Color(0xFF4A5566);
  static const steel = Color(0xFF9AA9BB);
  static const steelDk = Color(0xFF5F6F84);
  static const honey = Color(0xFFF0B13A);
  static const honeyDk = Color(0xFFD99A26);
  static const honeyInk = Color(0xFF1D1406);
  static const grass = Color(0xFF5C9E3C);
  static const red = Color(0xFFD9433A);
  static const line = Color(0xFF141922);

  // dark
  static const bgDark = Color(0xFF12161D);
  static const bg2Dark = Color(0xFF181E27);
  static const cardDark = Color(0xFF1B222C);
  static const inkDark = Color(0xFFE9EEF4);
  static const ink2Dark = Color(0xFFA4B0C0);
  static const steelDark = Color(0xFF7B8CA2);
  static const steelDkDark = Color(0xFFC3CFDC);
  static const grassDark = Color(0xFF7CC257);
  static const lineDark = Color(0xFFE9EEF4);
}

class LozhkaTheme {
  static TextStyle _pixel({double size = 16, Color? color, FontWeight weight = FontWeight.w600}) {
    return GoogleFonts.pixelifySans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle _unbounded({double size = 16, Color? color, FontWeight weight = FontWeight.w600, double letterSpacing = 0}) {
    return GoogleFonts.unbounded(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle pixelStyle({double size = 16, Color? color}) => _pixel(size: size, color: color);
  static TextStyle headingStyle({double size = 28, Color? color}) => _unbounded(size: size, color: color, weight: FontWeight.w800, letterSpacing: -0.5);
  static TextStyle bodyStyle({double size = 14, Color? color}) => _unbounded(size: size, color: color);

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: LozhkaColors.bg,
      colorScheme: const ColorScheme.light(
        surface: LozhkaColors.bg,
        primary: LozhkaColors.honey,
        onPrimary: LozhkaColors.honeyInk,
        secondary: LozhkaColors.grass,
      ),
      textTheme: TextTheme(
        headlineLarge: _unbounded(size: 28, color: LozhkaColors.ink, weight: FontWeight.w800),
        bodyMedium: _unbounded(size: 14, color: LozhkaColors.ink),
        labelMedium: _pixel(size: 14, color: LozhkaColors.ink2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: LozhkaColors.bg,
        foregroundColor: LozhkaColors.ink,
        elevation: 0,
        titleTextStyle: _pixel(size: 22, color: LozhkaColors.ink),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LozhkaColors.bgDark,
      colorScheme: const ColorScheme.dark(
        surface: LozhkaColors.bgDark,
        primary: LozhkaColors.honey,
        onPrimary: LozhkaColors.honeyInk,
        secondary: LozhkaColors.grassDark,
      ),
      textTheme: TextTheme(
        headlineLarge: _unbounded(size: 28, color: LozhkaColors.inkDark, weight: FontWeight.w800),
        bodyMedium: _unbounded(size: 14, color: LozhkaColors.inkDark),
        labelMedium: _pixel(size: 14, color: LozhkaColors.ink2Dark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: LozhkaColors.bgDark,
        foregroundColor: LozhkaColors.inkDark,
        elevation: 0,
        titleTextStyle: _pixel(size: 22, color: LozhkaColors.inkDark),
      ),
    );
  }
}
