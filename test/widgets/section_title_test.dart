import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/section_title.dart';
import 'test_helpers.dart';

void main() {
  group('SectionTitle', () {
    testWidgets('renderiza título sin acento por defecto', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionTitle(title: 'Novedades'),
      ));

      expect(find.text('Novedades'), findsOneWidget);
    });

    testWidgets('muestra Container de 6px cuando showAccent=true', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionTitle(title: 'Descripción', showAccent: true),
      ));

      expect(find.text('Descripción'), findsOneWidget);

      // Find the accent bar — a Container with width 6.0
      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      final accentBars =
          containers.where((c) => c.constraints?.maxWidth == 6.0).toList();
      expect(accentBars.length, greaterThanOrEqualTo(1),
          reason: 'Debe existir un Container con width 6px (accent bar)');
    });

    testWidgets('renderiza icon + title cuando se pasa icon', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionTitle(title: 'Géneros', icon: Icons.category),
      ));

      expect(find.text('Géneros'), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('renderiza trailing cuando se pasa trailing', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SectionTitle(
          title: 'Populares',
          trailing: Text('Ver todo'),
        ),
      ));

      expect(find.text('Populares'), findsOneWidget);
      expect(find.text('Ver todo'), findsOneWidget);
    });
  });
}
