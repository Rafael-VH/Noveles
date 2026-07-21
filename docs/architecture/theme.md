# Theme

> Light/dark theme support via ThemeBloc with Material 3 design tokens.

## Overview

Noveles supports light and dark themes using Material 3 (`useMaterial3: true`). The default theme is **dark mode**. Theme switching is managed by `ThemeBloc` and applied at the `MaterialApp` level via `BlocBuilder<ThemeBloc, ThemeState>`.

## ThemeBloc

**File**: `lib/core/presentation/bloc/theme_bloc.dart`

| Event | Description |
|-------|-------------|
| `ThemeChanged` | Toggle between light and dark mode |

| State | Data | When |
|-------|------|------|
| `ThemeState` | `bool isDarkMode, ThemeData themeData` | Always (single state) |

- Default: `isDarkMode: true`, `DarkTheme.darkTheme`
- No persistence — theme resets to dark on app restart

**Events**: `lib/core/presentation/bloc/theme_event.dart` — `ThemeChanged(bool isDarkMode)`

**State**: `lib/core/presentation/bloc/theme_state.dart` — holds both the flag and the resolved `ThemeData`

## Theme Files

| File | Class | Purpose |
|------|-------|---------|
| `lib/core/utils/theme/dark_theme.dart` | `DarkTheme` | Dark theme definition |
| `lib/core/utils/theme/light_theme.dart` | `LightTheme` | Light theme definition |
| `lib/core/utils/theme/theme.dart` | — | Barrel export for both |

## Color System

Both themes share the same color structure with different values:

| Token | Dark | Light | Usage |
|-------|------|-------|-------|
| Primary | `#71A202` | `#71A202` | Accent green (same brand) |
| Secondary | `#6B6B80` | `#6B6B80` | Muted gray-lavender |
| Tertiary | `#3E9A7A` | `#3E9A7A` | Soft teal |
| Background | Dark surface | `#F8F8FC` | Screen background |
| Surface | Elevated cards | `#FFFFFF` | Card backgrounds |
| Error | `#B3261E` | `#B3261E` | Error states |

Dark theme uses `DarkColor` constants; light theme uses private `_LightColor` constants.

## Text Theme

Both themes define a complete `TextTheme` with 15 styles:

| Category | Styles | Usage |
|----------|--------|-------|
| Display | `Large`, `Medium`, `Small` | Splash, hero text |
| Headline | `Large`, `Medium`, `Small` | Screen titles |
| Title | `Large`, `Medium`, `Small` | Card titles, section headers |
| Body | `Large`, `Medium`, `Small` | Reading content, descriptions |
| Label | `Large`, `Medium`, `Small` | Buttons, chips, tabs |

Font weights range from `w300` (display large) to `w600` (headlines, titles, labels).

## Customization

Both themes customize all Material 3 component themes: `AppBarTheme`, `CardThemeData`, `ElevatedButtonThemeData`, `InputDecorationTheme`, `DialogThemeData`, `BottomSheetThemeData`, `SnackBarThemeData`, `ChipThemeData`, `SwitchThemeData`, `FloatingActionButtonThemeData`, and more. Page transitions use `CupertinoPageTransitionsBuilder` on both platforms.

## Related

- [App Feature](../features/app/README.md) — ThemeBloc provider in App
- [Routing](./routing.md) — ThemeBloc in MaterialApp.builder

← Back to [index](../README.md)
