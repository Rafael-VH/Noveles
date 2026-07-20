import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/shared/presentation/widgets/empty_state.dart';

void main() {
  group('EmptyState widget', () {
    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              message: 'No hay libros disponibles',
            ),
          ),
        ),
      );

      expect(find.text('No hay libros disponibles'), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
    });

    testWidgets('displays optional action button when onAction is provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              message: 'Sin resultados',
              actionLabel: 'Reintentar',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Sin resultados'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      expect(tapped, isTrue);
    });

    testWidgets('does not display action button when onAction is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              message: 'Vacío',
            ),
          ),
        ),
      );

      expect(find.text('Vacío'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
