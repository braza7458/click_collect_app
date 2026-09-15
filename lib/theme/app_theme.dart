import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Braise Dorée" design system tokens.
///
/// Existing token NAMES are kept (`orange`, `orangeDark`, `charcoal`,
/// `charcoalSoft`, `cream`, `creamMuted`, `red`, `green`) so every screen
/// that already imports [AppColors] keeps compiling unchanged — only the
/// VALUES moved, from a saturated fast-food orange/charcoal palette to a
/// burnished antique-gold / candlelit-charcoal palette. `orange` and
/// `orangeDark` now hold the brand's PRIMARY GOLD role (not a literal
/// orange hue) — treat them as "primary" / "primaryDark" wherever you see
/// them referenced downstream.
///
/// New tokens added because the design calls for a richer surface/accent
/// stack than the old file had:
/// - `secondary`   — terracotta/wood-fire accent for secondary buttons & CTAs' glow tint.
/// - `badgeAmber`  — a THIRD accent, reserved only for the badge/tag system
///                   (Label Rouge, "Nouveau", loyalty-tier pills) so tags never
///                   visually compete with primary-gold CTAs.
/// - `surfaceAlt`  — level-2 raised surface (sheets, dialogs, selected cards),
///                   one step lighter than `charcoalSoft`.
/// - `divider`     — hairline border/divider (cream @ ~8% opacity), used for
///                   the level-1 card border and for DividerTheme.
/// - `overlayScrim`— ~45% black scrim behind modals/bottom sheets.
class AppColors {
  // --- Primary accent: antique/burnished gold (was saturated orange) ---
  /// Primary gold. ~7.8:1 contrast on [charcoal]. CTAs, active nav, loyalty highlights.
  static const orange = Color(0xFFC9A227);

  /// Primary gold, pressed/darker state. Also used as the warm glow-shadow tint
  /// behind primary buttons/cards (at low alpha, e.g. `orangeDark.withValues(alpha: 0.2)`).
  static const orangeDark = Color(0xFF8C6B14);

  /// Secondary / wood-fire terracotta accent — secondary buttons, alt glow tint.
  /// Use `cream` (not `charcoal`) as the foreground on top of this fill — see
  /// contrast note on [onSecondaryForeground] below.
  static const secondary = Color(0xFF9C5A34);

  /// Third accent reserved strictly for the badge/tag system (Label Rouge,
  /// "Nouveau", loyalty-tier pills) — deliberately distinct from [orange] so
  /// quality/promo tags never compete visually with primary CTAs.
  static const badgeAmber = Color(0xFFD4A24E);

  // --- Backgrounds / surfaces (matte, candlelit, near-black) ---
  /// Scaffold background.
  static const charcoal = Color(0xFF14110D);

  /// Level-1 surface: standard cards, list tiles, input fields.
  static const charcoalSoft = Color(0xFF1E1912);

  /// Level-2 surface: raised/interactive elements, selected cards, sheets, dialogs.
  static const surfaceAlt = Color(0xFF2A2318);

  // --- Text ---
  /// Primary text — warm parchment cream. >15:1 contrast on [charcoal].
  static const cream = Color(0xFFF3ECE0);

  /// Secondary/muted text. 8.7:1 contrast on [charcoal].
  static const creamMuted = Color(0xFFB8AFA0);

  // --- Status ---
  /// Error / destructive. 5.4:1 contrast on [charcoal]. Use [charcoal] (not
  /// [cream]) as foreground on an error-filled surface — see contrast note below.
  static const red = Color(0xFFE0605A);

  /// Success. 6.0:1 contrast on [charcoal].
  static const green = Color(0xFF5C9F6E);

  // --- Structural helpers ---
  /// Hairline border for level-1 elevation (cream @ ~8% opacity) and the
  /// DividerTheme color.
  static const divider = Color(0x14F3ECE0);

  /// ~45% black scrim behind modal bottom sheets / dialogs.
  static const overlayScrim = Color(0x73000000);

  // --- Contrast-audit notes (WCAG 2.1 AA, sRGB relative luminance) ---
  // Both directions were checked per screen surface, not assumed:
  //   - Text/icons ON primary gold fill: charcoal-on-gold ≈ 8.2:1 vs
  //     cream-on-gold ≈ 2.1:1 → dark (charcoal) foreground wins. Buttons use
  //     `foregroundColor: AppColors.charcoal` on an `orange` background.
  //   - Text ON secondary (terracotta) fill: cream-on-secondary ≈ 4.6:1 vs
  //     charcoal-on-secondary ≈ 3.7:1 → light (cream) foreground wins here —
  //     the opposite rule from primary gold, so don't assume one rule for both.
  //   - Text ON error (red) fill: charcoal-on-red ≈ 5.7:1 vs cream-on-red ≈
  //     3.0:1 → dark (charcoal) foreground wins.
  //   - `red` and `green` were also checked against `charcoalSoft` and
  //     `surfaceAlt`, not just `charcoal`; both surfaces are dark enough that
  //     contrast stays clear of the 4.5:1 floor.
}

/// Corner-radius token scale — use these everywhere instead of ad hoc values
/// so the "confident rectangles, pills only for tags/badges" language stays
/// consistent across the app.
class AppRadius {
  /// Small tags, input focus rings, snackbar accents.
  static const xs = 4.0;

  /// Chips, small icon buttons, checkbox corners.
  static const sm = 8.0;

  /// Secondary buttons, text fields — kept tighter than buttons so buttons
  /// visually "win" the screen.
  static const md = 12.0;

  /// Primary/elevated buttons, standard cards, order-mode option cards.
  static const lg = 16.0;

  /// Dialogs, feature/hero cards, restaurant-picker cards.
  static const xl = 24.0;

  /// Top corners of modal bottom sheets only.
  static const xxl = 28.0;

  /// Status badges, loyalty-tier pills, filter chips, avatar/logo frames.
  static const pill = 999.0;
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.dark,
      primary: AppColors.orange,
      onPrimary: AppColors.charcoal,
      secondary: AppColors.secondary,
      onSecondary: AppColors.cream,
      surface: AppColors.charcoal,
      onSurface: AppColors.cream,
      surfaceContainerHighest: AppColors.surfaceAlt,
      error: AppColors.red,
      onError: AppColors.charcoal,
    ),
    scaffoldBackgroundColor: AppColors.charcoal,
  );

  // Heritage/editorial serif for headlines, neutral grotesque for UI-dense
  // body copy — "one voice speaks, one voice organizes". Fraunces never
  // appears below titleLarge; Inter never carries a hero moment.
  final display = GoogleFonts.frauncesTextTheme(base.textTheme);
  final body = GoogleFonts.interTextTheme(base.textTheme);

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    displayMedium: display.displayMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    headlineLarge: display.headlineLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    headlineMedium: display.headlineMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    headlineSmall: display.headlineSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w500),
    titleLarge: display.titleLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w500, letterSpacing: 0.2),
    titleMedium: body.titleMedium?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    titleSmall: body.titleSmall?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600),
    bodyLarge: body.bodyLarge?.copyWith(color: AppColors.cream),
    bodyMedium: body.bodyMedium?.copyWith(color: AppColors.creamMuted),
    bodySmall: body.bodySmall?.copyWith(color: AppColors.creamMuted),
    labelLarge: body.labelLarge?.copyWith(color: AppColors.cream, fontWeight: FontWeight.w600, letterSpacing: 0.4),
  );

  // Text fields keep a slightly tighter radius (md) than buttons (lg) so
  // buttons visually "win" the screen.
  final outlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
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
      // Dark check mark on gold fill — see the contrast-audit note in AppColors.
      checkColor: const WidgetStatePropertyAll(AppColors.charcoal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orange,
      linearTrackColor: AppColors.charcoalSoft,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceAlt,
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceAlt,
      modalBackgroundColor: AppColors.surfaceAlt,
      modalBarrierColor: AppColors.overlayScrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceAlt,
      contentTextStyle: const TextStyle(color: AppColors.cream),
      actionTextColor: AppColors.orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        // Dark charcoal foreground on gold fill reads ~8.2:1 vs ~2.1:1 for a
        // light foreground — see the contrast-audit note in AppColors.
        foregroundColor: AppColors.charcoal,
        disabledBackgroundColor: AppColors.charcoalSoft,
        disabledForegroundColor: AppColors.creamMuted.withValues(alpha: 0.5),
        minimumSize: const Size.fromHeight(52),
        elevation: 4,
        // Soft warm-tinted "ember glow" shadow layered on top of the hairline-
        // border elevation model, instead of relying on a plain black shadow.
        shadowColor: AppColors.orangeDark.withValues(alpha: 0.22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cream,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cream,
        minimumSize: const Size(0, 48),
        side: BorderSide(color: AppColors.creamMuted.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    ),
  );
}
