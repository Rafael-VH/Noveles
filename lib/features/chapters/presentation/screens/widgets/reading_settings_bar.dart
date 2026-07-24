import 'package:flutter/material.dart';

enum ReadingMode { normal, sepia, night }

class ReadingSettingsBar extends StatelessWidget {
  final double fontSize;
  final ReadingMode mode;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<ReadingMode> onModeChanged;

  const ReadingSettingsBar({
    super.key,
    required this.fontSize,
    required this.mode,
    required this.onFontSizeChanged,
    required this.onModeChanged,
  });

  static const double minFontSize = 12.0;
  static const double maxFontSize = 28.0;

  String _modeLabel(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.normal:
        return 'Normal';
      case ReadingMode.sepia:
        return 'Sepia';
      case ReadingMode.night:
        return 'Night';
    }
  }

  IconData _modeIcon(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.normal:
        return Icons.light_mode;
      case ReadingMode.sepia:
        return Icons.auto_stories;
      case ReadingMode.night:
        return Icons.dark_mode;
    }
  }

  ReadingMode _nextMode(ReadingMode current) {
    switch (current) {
      case ReadingMode.normal:
        return ReadingMode.sepia;
      case ReadingMode.sepia:
        return ReadingMode.night;
      case ReadingMode.night:
        return ReadingMode.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Font size controls
            IconButton(
              key: const Key('font_decrease'),
              onPressed: fontSize > minFontSize
                  ? () => onFontSizeChanged(fontSize - 2.0)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Decrease font size',
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 40),
              alignment: Alignment.center,
              child: Text(
                '${fontSize.round()}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            IconButton(
              key: const Key('font_increase'),
              onPressed: fontSize < maxFontSize
                  ? () => onFontSizeChanged(fontSize + 2.0)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Increase font size',
            ),
            const SizedBox(width: 24),
            // Reading mode toggle
            IconButton(
              key: const Key('mode_toggle'),
              onPressed: () => onModeChanged(_nextMode(mode)),
              icon: Icon(_modeIcon(mode)),
              tooltip: 'Reading mode: ${_modeLabel(mode)}',
            ),
            const SizedBox(width: 4),
            Text(
              _modeLabel(mode),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
