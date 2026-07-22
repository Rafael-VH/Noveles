import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/section_header.dart';
import 'test_helpers.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('renderiza título', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionHeader(title: 'Novedades'),
      ));

      expect(find.text('Novedades'), findsOneWidget);
    });

    testWidgets('renderiza icon + title cuando se pasa icon', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionHeader(title: 'Géneros', icon: Icons.category),
      ));

      expect(find.text('Géneros'), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('renderiza trailing cuando se pasa trailing', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionHeader(
          title: 'Populares',
          trailing: Text('Ver todo'),
        ),
      ));

      expect(find.text('Populares'), findsOneWidget);
      expect(find.text('Ver todo'), findsOneWidget);
    });

    testWidgets('sin icon no renderiza Icon widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionHeader(title: 'Solo Título'),
      ));

      expect(find.byIcon(Icons.category), findsNothing);
      expect(find.text('Solo Título'), findsOneWidget);
    });

    testWidgets('sin trailing no renderiza trailing widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionHeader(title: 'Sin Trailing'),
      ));

      expect(find.text('Sin Trailing'), findsOneWidget);
      // Should not find any extra widget beyond the title
    });
  });
}
