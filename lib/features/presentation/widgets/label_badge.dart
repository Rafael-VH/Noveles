import 'package:flutter/material.dart';
import 'package:noveles/core/utils/color_utils.dart';

class LabelBadge extends StatelessWidget {
  final String name;
  final String color;
  final double fontSize;

  const LabelBadge({
    super.key,
    required this.name,
    required this.color,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = ColorUtils.fromHex(color);
    final textColor = ColorUtils.textColor(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
    );
  }
}
