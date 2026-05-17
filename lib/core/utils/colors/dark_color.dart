import 'package:flutter/material.dart';

class DarkColor {
  // ── Primary: Green accent ─────────────────────────────────
  static const primary = Color(0xFF71A202);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF2D4200);
  static const onPrimaryContainer = Color(0xFFC5F06A);

  // ── Secondary: Muted gray-lavender ─────────────────────────
  static const secondary = Color(0xFFA0A0B8);
  static const onSecondary = Color(0xFF1A1A2E);
  static const secondaryContainer = Color(0xFF33334E);
  static const onSecondaryContainer = Color(0xFFD0D0E4);

  // ── Tertiary: Soft teal ────────────────────────────────────
  static const tertiary = Color(0xFF6EC8A8);
  static const onTertiary = Color(0xFF1A1A2E);
  static const tertiaryContainer = Color(0xFF004D40);
  static const onTertiaryContainer = Color(0xFFB0F0D0);

  // ── Background & Surface hierarchy ─────────────────────────
  // Scaffold / full-screen backgrounds
  static const background = Color(0xFF191A22);
  static const onBackground = Color(0xFFE8E8F0);

  // Card / container surfaces (lightest → darkest)
  static const surfaceLowest = Color(0xFF12121A);
  static const surfaceLow = Color(0xFF1C1C2E);
  static const surface = Color(0xFF24243C);
  static const surfaceHigh = Color(0xFF2C2C46);
  static const surfaceHighest = Color(0xFF343450);

  static const onSurface = Color(0xFFE8E8F0);
  static const surfaceVariant = Color(0xFF2E2E48);
  static const onSurfaceVariant = Color(0xFFB8B8CC);
  static const onSurfaceDim = Color(0xFF8888A0);

  static const inverseSurface = Color(0xFFE8E8F0);
  static const inverseOnSurface = Color(0xFF1A1A2E);

  // ── Outline / Dividers ────────────────────────────────────
  static const outline = Color(0xFF444462);
  static const outlineVariant = Color(0xFF363654);

  // ── Error ──────────────────────────────────────────────────
  static const error = Color(0xFFCF6679);
  static const onError = Color(0xFF1A1A2E);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // ── Shadow & Scrim ────────────────────────────────────────
  static const shadow = Color(0xFF000000);
  static const scrim = Color(0xFF000000);
}
