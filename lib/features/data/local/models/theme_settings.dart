import 'package:flutter/material.dart';

class ThemeSettings {
  final Color primaryColor;
  final Color accentColor;
  final Brightness brightness;

  ThemeSettings({
    required this.primaryColor,
    required this.accentColor,
    required this.brightness,
  });

  ThemeSettings copyWith({
    Color? primaryColor,
    Color? accentColor,
    Brightness? brightness,
  }) {
    return ThemeSettings(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      brightness: brightness ?? this.brightness,
    );
  }
}
