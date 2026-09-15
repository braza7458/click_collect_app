import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const orange = Color(0xFFF07A1E);
  static const orangeDark = Color(0xFFD9660E);
  static const charcoal = Color(0xFF1C140F);
  static const charcoalSoft = Color(0xFF2A1F17);
  static const cream = Color(0xFFF6ECD6);
  static const creamMuted = Color(0xFFC9BDA4);
  static const red = Color(0xFFC8272B);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.dark,
      primary: AppColors.orange,
      surface: AppColors.charcoal,
    ),
    scaffoldBackgroundColor: AppColors.charcoal,
  );

  final display = GoogleFonts.oswaldTextTheme(base.textTheme);
  final body = GoogleFonts.rubikTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: body.copyWith(
      displayLarge: display.displayLarge?.copyWith(color: AppColors.cream),
      displayMedium: display.displayMedium?.copyWith(color: AppColors.cream),
      headlineLarge: display.headlineLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
      headlineMedium: display.headlineMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
      headlineSmall: display.headlineSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
      titleLarge: display.titleLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w500, letterSpacing: 0.4),
      titleMedium: body.titleMedium?.copyWith(color: AppColors.cream),
      bodyLarge: body.bodyLarge?.copyWith(color: AppColors.cream),
      bodyMedium: body.bodyMedium?.copyWith(color: AppColors.creamMuted),
      labelLarge: body.labelLarge?.copyWith(color: AppColors.cream, letterSpacing: 0.6),
    ),
  );
}
