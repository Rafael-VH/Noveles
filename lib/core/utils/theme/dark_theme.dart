import 'package:flutter/material.dart';
import 'package:noveles/core/utils/colors/color.dart';

class DarkTheme {
  final List<ThemeData> darkAll = [
    ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: DarkColor.primaryColor,
        onPrimary: DarkColor.onPrimaryColor,
        secondary: DarkColor.secondaryColor,
        onSecondary: DarkColor.onSecondaryColor,
        error: Colors.red,
        onError: Colors.redAccent,
        surface: DarkColor.surfaceColor,
        onSurface: DarkColor.onSurfaceColor,
      ),
    ),
    ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: DarkColor.primaryColor,
        onPrimary: DarkColor.onPrimaryColor,
        secondary: DarkColor.secondaryColor,
        onSecondary: DarkColor.onSecondaryColor,
        error: Colors.red,
        onError: Colors.redAccent,
        surface: DarkColor.surfaceColor,
        onSurface: DarkColor.onSurfaceColor,
      ),
    ),
  ];

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: textDarkTheme,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: DarkColor.primaryColor,
      onPrimary: DarkColor.onPrimaryColor,
      secondary: DarkColor.secondaryColor,
      onSecondary: DarkColor.onSecondaryColor,
      error: Colors.red,
      onError: Colors.redAccent,
      surface: DarkColor.primaryColor,
      onSurface: DarkColor.onSurfaceColor,
      shadow: DarkColor.primaryColor,
    ),
  );

  static final ThemeData greenTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: textDarkTheme,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: DarkColor.primaryColor,
      onPrimary: DarkColor.onPrimaryColor,
      secondary: DarkColor.secondaryColor,
      onSecondary: DarkColor.onSecondaryColor,
      error: Colors.red,
      onError: Colors.redAccent,
      surface: DarkColor.surfaceColor,
      onSurface: DarkColor.onSurfaceColor,
    ),
  );

  //  
  static const TextTheme textDarkTheme = TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.white,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      color: Colors.white70,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      color: Colors.white60,
      fontWeight: FontWeight.normal,
    ),
    displayLarge: TextStyle(
      fontSize: 34.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      fontSize: 30.0,
      color: Colors.white70,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      fontSize: 26.0,
      color: Colors.white60,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      fontSize: 24.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontSize: 22.0,
      color: Colors.white70,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontSize: 20.0,
      color: Colors.white60,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(
      fontSize: 14.0,
      color: Colors.white70,
      fontWeight: FontWeight.bold,
    ),
    labelSmall: TextStyle(
      fontSize: 12.0,
      color: Colors.white60,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 20.0,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 18.0,
      color: Colors.white70,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 16.0,
      color: Colors.white60,
      fontWeight: FontWeight.w500,
    ),
  );
}
