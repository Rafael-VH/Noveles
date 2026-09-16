import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noveles/core/utils/colors/dark_color.dart';

/// Light-mode color tokens — mirrors [DarkColor] structure.
class _LightColor {
  // ── Primary: Green accent ─────────────────────────────────
  static const Color primary = Color(0xFF71A202);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD4ED9A);
  static const Color onPrimaryContainer = Color(0xFF1A3200);

  // ── Secondary: Muted gray-lavender ─────────────────────────
  static const Color secondary = Color(0xFF6B6B80);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE8E0F0);
  static const Color onSecondaryContainer = Color(0xFF1E1A2E);

  // ── Tertiary: Soft teal ────────────────────────────────────
  static const Color tertiary = Color(0xFF3E9A7A);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFB0F0D0);
  static const Color onTertiaryContainer = Color(0xFF003320);

  // ── Background & Surface hierarchy ─────────────────────────
  static const Color background = Color(0xFFF8F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF5F5F8);
  static const Color surfaceHigh = Color(0xFFFFFFFF);
  static const Color surfaceHighest = Color(0xFFECECF4);

  static const Color onSurface = Color(0xFF1A1A2E);
  static const Color onSurfaceVariant = Color(0xFF6B6B80);
  static const Color onSurfaceDim = Color(0xFF9E9EB0);

  static const Color inverseSurface = Color(0xFF24243C);

  // ── Outline / Dividers ────────────────────────────────────
  static const Color outline = Color(0xFFB8B8CC);
  static const Color outlineVariant = Color(0xFFD8D8E0);

  // ── Error ──────────────────────────────────────────────────
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // ── Shadow & Scrim ────────────────────────────────────────
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);

  // ── Snackbar / Tooltip (dark overlays on light backgrounds) ─
  static const Color inverseOnSurface = Color(0xFFE8E8F0);
}

/// Light theme definition for the app.
class LightTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _LightColor.background,

    // ── Color Scheme ──────────────────────────────────────────
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // Primary — green accent (same brand as dark)
      primary: _LightColor.primary,
      onPrimary: _LightColor.onPrimary,
      primaryContainer: _LightColor.primaryContainer,
      onPrimaryContainer: _LightColor.onPrimaryContainer,

      // Secondary — muted gray-lavender
      secondary: _LightColor.secondary,
      onSecondary: _LightColor.onSecondary,
      secondaryContainer: _LightColor.secondaryContainer,
      onSecondaryContainer: _LightColor.onSecondaryContainer,

      // Tertiary — soft teal
      tertiary: _LightColor.tertiary,
      onTertiary: _LightColor.onTertiary,
      tertiaryContainer: _LightColor.tertiaryContainer,
      onTertiaryContainer: _LightColor.onTertiaryContainer,

      // Surface hierarchy
      surface: _LightColor.surface,
      onSurface: _LightColor.onSurface,
      surfaceContainerHighest: _LightColor.surfaceHighest,
      onSurfaceVariant: _LightColor.onSurfaceVariant,

      inverseSurface: _LightColor.inverseSurface,

      // Stroke
      outline: _LightColor.outline,
      outlineVariant: _LightColor.outlineVariant,

      // Shadows
      shadow: _LightColor.shadow,
      scrim: _LightColor.scrim,

      // Error
      error: _LightColor.error,
      onError: _LightColor.onError,
      errorContainer: _LightColor.errorContainer,
      onErrorContainer: _LightColor.onErrorContainer,
    ),

    // ── Text Theme ────────────────────────────────────────────
    textTheme: textLightTheme,

    // ── AppBar ────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _LightColor.onSurface,
        letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: _LightColor.onSurface),
    ),

    // ── Bottom Navigation ────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _LightColor.surface,
      indicatorColor: _LightColor.primaryContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _LightColor.primary);
        }
        return const IconThemeData(color: _LightColor.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _LightColor.primary,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _LightColor.onSurfaceVariant,
        );
      }),
    ),

    // ── Navigation Drawer ────────────────────────────────────
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: _LightColor.surface,
      indicatorColor: _LightColor.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileHeight: 56,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _LightColor.onSurface,
          );
        }
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _LightColor.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _LightColor.primary);
        }
        return const IconThemeData(color: _LightColor.onSurfaceVariant);
      }),
    ),

    // ── Cards ─────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: _LightColor.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _LightColor.outlineVariant, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),

    // ── Elevated Buttons ─────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _LightColor.primary,
        foregroundColor: _LightColor.onPrimary,
        disabledBackgroundColor: _LightColor.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: _LightColor.onSurface.withValues(alpha: 0.38),
      elevation: 2.0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // ── Text Buttons ─────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _LightColor.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // ── Outlined Buttons ─────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _LightColor.primary,
        side: const BorderSide(color: _LightColor.outline),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // ── Input Fields ─────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _LightColor.surfaceLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _LightColor.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _LightColor.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _LightColor.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _LightColor.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _LightColor.error, width: 2),
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        color: _LightColor.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 14,
        color: _LightColor.primary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: _LightColor.onSurfaceDim,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: _LightColor.onSurfaceVariant,
      suffixIconColor: _LightColor.onSurfaceVariant,
      errorStyle: const TextStyle(
        fontSize: 12,
        color: _LightColor.error,
        fontWeight: FontWeight.w400,
      ),
    ),

    // ── Text Selection ──────────────────────────────────────
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _LightColor.primary,
      selectionColor: Color(0x4D71A202),
      selectionHandleColor: _LightColor.primary,
    ),

    // ── Dialogs ──────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: _LightColor.surfaceHigh,
      elevation: 8,
      shadowColor: _LightColor.shadow.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _LightColor.onSurface,
        letterSpacing: 0,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _LightColor.onSurfaceVariant,
        letterSpacing: 0.25,
        height: 1.5,
      ),
    ),

    // ── Bottom Sheets ───────────────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _LightColor.surfaceHigh,
      elevation: 8,
      shadowColor: _LightColor.shadow.withValues(alpha: 0.15),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // ── SnackBar ─────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _LightColor.surfaceHighest,
      contentTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _LightColor.inverseOnSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actionTextColor: _LightColor.primary,
    ),

    // ── Progress Indicator ──────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _LightColor.primary,
      linearTrackColor: _LightColor.onSurfaceDim,
      circularTrackColor: _LightColor.onSurfaceDim,
    ),

    // ── Chips ────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: _LightColor.surfaceLow,
      selectedColor: _LightColor.primaryContainer,
      disabledColor: _LightColor.surfaceLow,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _LightColor.onSurfaceVariant,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _LightColor.onSurfaceVariant,
      ),
      side: const BorderSide(color: _LightColor.outlineVariant),
      selectedShadowColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      iconTheme: const IconThemeData(
        color: _LightColor.onSurfaceVariant,
        size: 18,
      ),
    ),

    // ── Switch ───────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _LightColor.primary;
        }
        return _LightColor.onSurfaceDim;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _LightColor.primary.withValues(alpha: 0.5);
        }
        return _LightColor.outlineVariant;
      }),
    ),

    // ── Checkbox ─────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _LightColor.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _LightColor.onPrimary;
        }
        return _LightColor.onSurface;
      }),
      side: const BorderSide(color: _LightColor.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // ── Radio ────────────────────────────────────────────────
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _LightColor.primary;
        }
        return _LightColor.onSurfaceVariant;
      }),
    ),

    // ── Floating Action Button ───────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _LightColor.primaryContainer,
      foregroundColor: _LightColor.onPrimaryContainer,
      elevation: 0,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ── Divider ──────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: _LightColor.outlineVariant,
      thickness: 0.5,
      space: 1,
    ),

    // ── Popup Menu ──────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: _LightColor.surfaceHigh,
      elevation: 8,
      shadowColor: _LightColor.shadow.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _LightColor.onSurface,
      ),
    ),

    // ── Tooltip ──────────────────────────────────────────────
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: _LightColor.surfaceHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _LightColor.inverseOnSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // ── Icons ────────────────────────────────────────────────
    iconTheme: const IconThemeData(
      color: _LightColor.onSurfaceVariant,
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: _LightColor.primary,
      size: 24,
    ),

    // ── Visual ───────────────────────────────────────────────
    visualDensity: VisualDensity.comfortable,
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // ── Page Transitions ────────────────────────────────────
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ── Text Theme ─────────────────────────────────────────────
  static const TextTheme textLightTheme = TextTheme(
    // Display — for splash screens, large hero text
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.25,
      color: _LightColor.onSurface,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: _LightColor.onSurface,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: _LightColor.onSurface,
    ),

    // Headlines — for screen titles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: _LightColor.onSurface,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: _LightColor.onSurface,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: _LightColor.onSurface,
    ),

    // Titles — for card titles, section headers
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: _LightColor.onSurface,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: _LightColor.onSurface,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: _LightColor.onSurface,
    ),

    // Body — for reading content
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
      color: _LightColor.onSurface,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
      color: _LightColor.onSurfaceVariant,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: _LightColor.onSurfaceVariant,
    ),

    // Labels — for buttons, chips, tabs
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: _LightColor.onSurface,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: _LightColor.onSurface,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: _LightColor.onSurfaceVariant,
    ),
  );
}
