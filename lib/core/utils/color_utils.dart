import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static bool isLight(String hex) {
    final color = fromHex(hex);
    return color.computeLuminance() > 0.5;
  }

  static Color textColor(String hex) {
    return isLight(hex) ? Colors.black87 : Colors.white;
  }

  static const List<String> palette = [
    '#71A202',
    '#E53935',
    '#1E88E5',
    '#8E24AA',
    '#00ACC1',
    '#FB8C00',
    '#43A047',
    '#6D4C41',
  ];
}
