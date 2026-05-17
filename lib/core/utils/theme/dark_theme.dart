import 'package:flutter/material.dart';
import 'package:noveles/core/utils/colors/color.dart';

class DarkTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DarkColor.background,

    // ── Color Scheme ──────────────────────────────────────────
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      // Primary — green accent
      primary: DarkColor.primary,
      onPrimary: DarkColor.onPrimary,
      primaryContainer: DarkColor.primaryContainer,
      onPrimaryContainer: DarkColor.onPrimaryContainer,

      // Secondary — muted gray-lavender
      secondary: DarkColor.secondary,
      onSecondary: DarkColor.onSecondary,
      secondaryContainer: DarkColor.secondaryContainer,
      onSecondaryContainer: DarkColor.onSecondaryContainer,

      // Tertiary — soft teal
      tertiary: DarkColor.tertiary,
      onTertiary: DarkColor.onTertiary,
      tertiaryContainer: DarkColor.tertiaryContainer,
      onTertiaryContainer: DarkColor.onTertiaryContainer,

      // Surface hierarchy
      surface: DarkColor.surface,
      onSurface: DarkColor.onSurface,
      surfaceContainerHighest: DarkColor.surfaceHighest,
      onSurfaceVariant: DarkColor.onSurfaceVariant,

      inverseSurface: DarkColor.inverseSurface,

      // Stroke
      outline: DarkColor.outline,
      outlineVariant: DarkColor.outlineVariant,

      // Shadows
      shadow: DarkColor.shadow,
      scrim: DarkColor.scrim,

      // Error
      error: DarkColor.error,
      onError: DarkColor.onError,
      errorContainer: DarkColor.errorContainer,
      onErrorContainer: DarkColor.onErrorContainer,
    ),

    // ── Text Theme ────────────────────────────────────────────
    textTheme: textDarkTheme,

    // ── AppBar ────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: DarkColor.onSurface,
        letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: DarkColor.onSurface),
    ),

    // ── Bottom Navigation ────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: DarkColor.surfaceHigh,
      indicatorColor: DarkColor.primaryContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: DarkColor.primary);
        }
        return const IconThemeData(color: DarkColor.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DarkColor.primary,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: DarkColor.onSurfaceVariant,
        );
      }),
    ),

    // ── Cards ─────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: DarkColor.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DarkColor.outlineVariant, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),

    // ── Elevated Buttons ─────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColor.primary,
        foregroundColor: DarkColor.onPrimary,
        disabledBackgroundColor: DarkColor.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: DarkColor.onSurface.withValues(alpha: 0.38),
        elevation: 0,
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
        foregroundColor: DarkColor.primary,
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
        foregroundColor: DarkColor.primary,
        side: const BorderSide(color: DarkColor.outline),
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
      fillColor: DarkColor.surfaceLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkColor.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkColor.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkColor.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkColor.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DarkColor.error, width: 2),
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        color: DarkColor.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 14,
        color: DarkColor.primary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: DarkColor.onSurfaceDim,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: DarkColor.onSurfaceVariant,
      suffixIconColor: DarkColor.onSurfaceVariant,
      errorStyle: const TextStyle(
        fontSize: 12,
        color: DarkColor.error,
        fontWeight: FontWeight.w400,
      ),
    ),

    // ── Text Selection ──────────────────────────────────────
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: DarkColor.primary,
      selectionColor: Color(0x4D71A202),
      selectionHandleColor: DarkColor.primary,
    ),

    // ── Dialogs ──────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: DarkColor.surfaceHigh,
      elevation: 8,
      shadowColor: DarkColor.shadow.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: DarkColor.onSurface,
        letterSpacing: 0,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DarkColor.onSurfaceVariant,
        letterSpacing: 0.25,
        height: 1.5,
      ),
    ),

    // ── Bottom Sheets ───────────────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: DarkColor.surfaceHigh,
      elevation: 8,
      shadowColor: DarkColor.shadow.withValues(alpha: 0.4),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // ── SnackBar ─────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: DarkColor.surfaceHighest,
      contentTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DarkColor.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actionTextColor: DarkColor.primary,
    ),

    // ── Progress Indicator ──────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: DarkColor.primary,
      linearTrackColor: DarkColor.onSurfaceDim,
      circularTrackColor: DarkColor.onSurfaceDim,
    ),

    // ── Chips ────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: DarkColor.surfaceLow,
      selectedColor: DarkColor.primaryContainer,
      disabledColor: DarkColor.surfaceLow,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: DarkColor.onSurfaceVariant,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: DarkColor.onSurfaceVariant,
      ),
      side: const BorderSide(color: DarkColor.outlineVariant),
      selectedShadowColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      iconTheme: const IconThemeData(
        color: DarkColor.onSurfaceVariant,
        size: 18,
      ),
    ),

    // ── Switch ───────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkColor.primary;
        }
        return DarkColor.onSurfaceDim;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkColor.primary.withValues(alpha: 0.5);
        }
        return DarkColor.outlineVariant;
      }),
    ),

    // ── Checkbox ─────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkColor.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkColor.onPrimary;
        }
        return DarkColor.onSurface;
      }),
      side: const BorderSide(color: DarkColor.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // ── Radio ────────────────────────────────────────────────
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkColor.primary;
        }
        return DarkColor.onSurfaceVariant;
      }),
    ),

    // ── Floating Action Button ───────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: DarkColor.primaryContainer,
      foregroundColor: DarkColor.onPrimaryContainer,
      elevation: 0,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ── Divider ──────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: DarkColor.outlineVariant,
      thickness: 0.5,
      space: 1,
    ),

    // ── Popup Menu ──────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: DarkColor.surfaceHigh,
      elevation: 8,
      shadowColor: DarkColor.shadow.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DarkColor.onSurface,
      ),
    ),

    // ── Tooltip ──────────────────────────────────────────────
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: DarkColor.surfaceHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DarkColor.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // ── Icons ────────────────────────────────────────────────
    iconTheme: const IconThemeData(
      color: DarkColor.onSurfaceVariant,
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: DarkColor.primary,
      size: 24,
    ),

    // ── Visual ───────────────────────────────────────────────
    visualDensity: VisualDensity.comfortable,
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // ── Page Transitions ────────────────────────────────────
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ── Text Theme ─────────────────────────────────────────────
  static const TextTheme textDarkTheme = TextTheme(
    // Display — for splash screens, large hero text
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.25,
      color: DarkColor.onSurface,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: DarkColor.onSurface,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: DarkColor.onSurface,
    ),

    // Headlines — for screen titles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: DarkColor.onSurface,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: DarkColor.onSurface,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: DarkColor.onSurface,
    ),

    // Titles — for card titles, section headers
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: DarkColor.onSurface,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: DarkColor.onSurface,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: DarkColor.onSurface,
    ),

    // Body — for reading content
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
      color: DarkColor.onSurface,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
      color: DarkColor.onSurfaceVariant,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: DarkColor.onSurfaceVariant,
    ),

    // Labels — for buttons, chips, tabs
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: DarkColor.onSurface,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: DarkColor.onSurface,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: DarkColor.onSurfaceVariant,
    ),
  );
}
