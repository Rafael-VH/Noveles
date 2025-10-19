import 'package:flutter/material.dart';
import 'package:noveles/core/utils/colors/color.dart';

class LightTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: textLightTheme,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: ColorsTheme.color3,
      onPrimary: ColorsTheme.color4,
      secondary: ColorsTheme.color5,
      onSecondary: ColorsTheme.color6,
      error: ColorsTheme.color15,
      onError: ColorsTheme.color16,
      surface: ColorsTheme.color8,
      onSurface: ColorsTheme.color7,
      inversePrimary: ColorsTheme.color9,
      inverseSurface: ColorsTheme.color10,
      outline: ColorsTheme.color13,
      scrim: ColorsTheme.color12,
      shadow: ColorsTheme.color14,
      tertiary: ColorsTheme.color11,
    ),
  );

  static final ThemeData blueTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: textLightTheme,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: LightColor.primaryColor,
      onPrimary: LightColor.onPrimaryColor,
      secondary: LightColor.secondaryColor,
      onSecondary: LightColor.onSecondaryColor,
      error: Colors.red,
      onError: Colors.redAccent,
      surface: LightColor.surfaceColor,
      onSurface: LightColor.onSurfaceColor,
    ),
  );

  //
  static const TextTheme textLightTheme = TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.black,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      color: Colors.black87,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      color: Colors.black54,
      fontWeight: FontWeight.normal,
    ),
    displayLarge: TextStyle(
      fontSize: 34.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      fontSize: 30.0,
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      fontSize: 26.0,
      color: Colors.black54,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      fontSize: 24.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontSize: 22.0,
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontSize: 20.0,
      color: Colors.black54,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(
      fontSize: 14.0,
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    labelSmall: TextStyle(
      fontSize: 12.0,
      color: Colors.black54,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 20.0,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 18.0,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 16.0,
      color: Colors.black54,
      fontWeight: FontWeight.w500,
    ),
  );
}
