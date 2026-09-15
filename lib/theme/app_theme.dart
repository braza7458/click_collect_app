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
  static const green = Color(0xFF4CAF6D);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.dark,
      primary: AppColors.orange,
      surface: AppColors.charcoal,
      error: AppColors.red,
    ),
    scaffoldBackgroundColor: AppColors.charcoal,
  );

  final display = GoogleFonts.oswaldTextTheme(base.textTheme);
  final body = GoogleFonts.rubikTextTheme(base.textTheme);

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(color: AppColors.cream),
    displayMedium: display.displayMedium?.copyWith(color: AppColors.cream),
    headlineLarge: display.headlineLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    headlineMedium: display.headlineMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    headlineSmall: display.headlineSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    titleLarge: display.titleLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w500, letterSpacing: 0.4),
    titleMedium: body.titleMedium?.copyWith(color: AppColors.cream),
    titleSmall: body.titleSmall?.copyWith(color: AppColors.cream),
    bodyLarge: body.bodyLarge?.copyWith(color: AppColors.cream),
    bodyMedium: body.bodyMedium?.copyWith(color: AppColors.creamMuted),
    bodySmall: body.bodySmall?.copyWith(color: AppColors.creamMuted),
    labelLarge: body.labelLarge?.copyWith(color: AppColors.cream, letterSpacing: 0.6),
  );

  final outlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.cream),
      titleTextStyle: textTheme.headlineSmall,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.charcoalSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.creamMuted),
      hintStyle: TextStyle(color: AppColors.creamMuted.withValues(alpha: 0.6)),
      errorStyle: const TextStyle(color: AppColors.red),
      border: outlineBorder,
      enabledBorder: outlineBorder.copyWith(
        borderSide: BorderSide(color: AppColors.creamMuted.withValues(alpha: 0.2)),
      ),
      focusedBorder: outlineBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.orange, width: 1.6),
      ),
      errorBorder: outlineBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.red, width: 1.2),
      ),
      focusedErrorBorder: outlineBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.red, width: 1.6),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.orange;
        return Colors.transparent;
      }),
      side: BorderSide(color: AppColors.creamMuted.withValues(alpha: 0.6), width: 1.4),
      checkColor: const WidgetStatePropertyAll(AppColors.charcoal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orange,
      linearTrackColor: AppColors.charcoalSoft,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.charcoalSoft,
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.charcoalSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.charcoalSoft,
      contentTextStyle: const TextStyle(color: AppColors.cream),
      actionTextColor: AppColors.orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(color: AppColors.creamMuted.withValues(alpha: 0.15)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.charcoal,
        disabledBackgroundColor: AppColors.charcoalSoft,
        disabledForegroundColor: AppColors.creamMuted.withValues(alpha: 0.5),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cream,
        minimumSize: const Size(0, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cream,
        minimumSize: const Size(0, 48),
        side: BorderSide(color: AppColors.creamMuted.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
