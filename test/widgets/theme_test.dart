import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/core/utils/theme/light_theme.dart';
import 'package:noveles/core/utils/theme/dark_theme.dart';

void main() {
  group('LightTheme', () {
    test('cardTheme.elevation defaults to 2.0', () {
      final theme = LightTheme.lightTheme;
      expect(theme.cardTheme.elevation, 2.0);
    });
  });

  group('DarkTheme', () {
    test('cardTheme.elevation defaults to 2.0', () {
      final theme = DarkTheme.darkTheme;
      expect(theme.cardTheme.elevation, 2.0);
    });
  });
}
