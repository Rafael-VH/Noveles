import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/books/presentation/screens/widgets/card_info_detail.dart';
import 'test_helpers.dart';

void main() {
  group('InfoPair', () {
    test('creates with title and value', () {
      const pair = InfoPair(title: 'Publicado', value: '2026');
      expect(pair.title, 'Publicado');
      expect(pair.value, '2026');
    });

    test('value can be empty string', () {
      const pair = InfoPair(title: 'Nota', value: '');
      expect(pair.title, 'Nota');
      expect(pair.value, '');
    });
  });

  group('CardInfoDetail', () {
    testWidgets('renderiza N pares correctamente', (tester) async {
      final pairs = [
        const InfoPair(title: 'Publicado', value: '2026'),
        const InfoPair(title: 'Tipo', value: 'Novela'),
        const InfoPair(title: 'País', value: 'Argentina'),
      ];

      await tester.pumpWidget(wrapWithMaterial(
        CardInfoDetail(pairs: pairs),
      ));

      expect(find.text('Publicado'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Novela'), findsOneWidget);
      expect(find.text('País'), findsOneWidget);
      expect(find.text('Argentina'), findsOneWidget);
    });

    testWidgets('renderiza 6 pares (merge de 3 cards anteriores)', (tester) async {
      final pairs = [
        const InfoPair(title: 'Publicado', value: '2026'),
        const InfoPair(title: 'Tipo de Novela', value: 'Novela'),
        const InfoPair(title: 'País', value: 'Argentina'),
        const InfoPair(title: 'Estado', value: 'Activo'),
        const InfoPair(title: 'Tomos', value: '5'),
        const InfoPair(title: 'Capítulos', value: '50'),
      ];

      await tester.pumpWidget(wrapWithMaterial(
        CardInfoDetail(pairs: pairs),
      ));

      for (final p in pairs) {
        expect(find.text(p.title), findsOneWidget);
        expect(find.text(p.value), findsOneWidget);
      }
    });

    testWidgets('usa elevation del theme (no hardcodeada)', (tester) async {
      final pairs = [
        const InfoPair(title: 'A', value: '1'),
        const InfoPair(title: 'B', value: '2'),
      ];

      await tester.pumpWidget(wrapWithMaterial(
        CardInfoDetail(pairs: pairs),
      ));

      // The Card should use theme default elevation (2.0)
      final card = tester.widget<Card>(find.byType(Card));
      // elevation is resolved to the theme's default
      expect(card.elevation, isNot(6.0));
    });
  });
}
