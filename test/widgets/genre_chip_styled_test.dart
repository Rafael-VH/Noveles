import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/genre_chip_styled.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'test_helpers.dart';

void main() {
  group('GenreChipStyled', () {
    testWidgets('renderiza icon y name para género conocido', (tester) async {
      final genre = GenreEntity(
        id: 1,
        createdAt: DateTime(2026),
        name: 'Aventura',
        description: '',
      );

      await tester.pumpWidget(wrapWithMaterial(
        GenreChipStyled(
          genre: genre,
          onTap: () {},
        ),
      ));

      expect(find.text('Aventura'), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget);
    });

    testWidgets('tap invoca onTap', (tester) async {
      final genre = GenreEntity(
        id: 1,
        createdAt: DateTime(2026),
        name: 'Romance',
        description: '',
      );
      bool tapped = false;

      await tester.pumpWidget(wrapWithMaterial(
        GenreChipStyled(
          genre: genre,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('género desconocido usa fallback Icons.book', (tester) async {
      final genre = GenreEntity(
        id: 1,
        createdAt: DateTime(2026),
        name: 'Desconocido',
        description: '',
      );

      await tester.pumpWidget(wrapWithMaterial(
        GenreChipStyled(
          genre: genre,
          onTap: () {},
        ),
      ));

      expect(find.byIcon(Icons.book), findsOneWidget);
    });
  });
}
