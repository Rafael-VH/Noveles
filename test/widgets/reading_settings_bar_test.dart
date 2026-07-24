import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/chapters/presentation/screens/widgets/reading_settings_bar.dart';

void main() {
  group('ReadingSettingsBar', () {
    testWidgets('displays current font size and mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSettingsBar(
              fontSize: 14.0,
              mode: ReadingMode.normal,
              onFontSizeChanged: (_) {},
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('14'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.byKey(const Key('font_decrease')), findsOneWidget);
      expect(find.byKey(const Key('font_increase')), findsOneWidget);
      expect(find.byKey(const Key('mode_toggle')), findsOneWidget);
    });

    testWidgets('calls onFontSizeChanged with decreased value on minus tap',
        (tester) async {
      double? reported;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSettingsBar(
              fontSize: 14.0,
              mode: ReadingMode.normal,
              onFontSizeChanged: (v) => reported = v,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('font_decrease')));
      expect(reported, 12.0);
    });

    testWidgets('calls onFontSizeChanged with increased value on plus tap',
        (tester) async {
      double? reported;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSettingsBar(
              fontSize: 14.0,
              mode: ReadingMode.normal,
              onFontSizeChanged: (v) => reported = v,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('font_increase')));
      expect(reported, 16.0);
    });

    testWidgets('decrease button disabled at min font size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSettingsBar(
              fontSize: ReadingSettingsBar.minFontSize,
              mode: ReadingMode.normal,
              onFontSizeChanged: (_) {},
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      final minusButton = tester.widget<IconButton>(
        find.byKey(const Key('font_decrease')),
      );
      expect(minusButton.onPressed, isNull);
    });

    testWidgets('increase button disabled at max font size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSettingsBar(
              fontSize: ReadingSettingsBar.maxFontSize,
              mode: ReadingMode.normal,
              onFontSizeChanged: (_) {},
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      final plusButton = tester.widget<IconButton>(
        find.byKey(const Key('font_increase')),
      );
      expect(plusButton.onPressed, isNull);
    });

    testWidgets('cycles mode: normal → sepia → night → normal', (tester) async {
      ReadingMode? reported;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSettingsBar(
              fontSize: 14.0,
              mode: ReadingMode.normal,
              onFontSizeChanged: (_) {},
              onModeChanged: (m) => reported = m,
            ),
          ),
        ),
      );

      // normal → sepia
      await tester.tap(find.byKey(const Key('mode_toggle')));
      expect(reported, ReadingMode.sepia);
    });

    testWidgets('cycles sepia → night', (tester) async {
      ReadingMode? reported;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSettingsBar(
              fontSize: 14.0,
              mode: ReadingMode.sepia,
              onFontSizeChanged: (_) {},
              onModeChanged: (m) => reported = m,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('mode_toggle')));
      expect(reported, ReadingMode.night);
    });

    testWidgets('cycles night → normal', (tester) async {
      ReadingMode? reported;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingSettingsBar(
              fontSize: 14.0,
              mode: ReadingMode.night,
              onFontSizeChanged: (_) {},
              onModeChanged: (m) => reported = m,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('mode_toggle')));
      expect(reported, ReadingMode.normal);
    });
  });
}
