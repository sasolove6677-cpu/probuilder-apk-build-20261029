import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF12151A);
  static const neonBlue = Color(0xFF00F0FF);
  static const cyberGreen = Color(0xFF00FF66);
  static const muted = Color(0xFF8A929E);
}

TextStyle appTextStyle(BuildContext context, [TextStyle? style]) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  return (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
    textStyle: style ?? const TextStyle(),
  );
}

ThemeData buildAppTheme({bool isArabic = false}) {
  final base = ThemeData.dark(useMaterial3: true);
  final localizedTextTheme = isArabic
      ? GoogleFonts.cairoTextTheme(base.textTheme)
      : GoogleFonts.interTextTheme(base.textTheme);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonBlue,
      secondary: AppColors.cyberGreen,
      surface: AppColors.surface,
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    textTheme: localizedTextTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.035),
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.neonBlue, width: 1.2),
      ),
    ),
  );
}
