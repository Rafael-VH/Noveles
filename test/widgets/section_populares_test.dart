import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/section_populares.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    setupCoverUrlService();
  });

  group('SectionPopulares', () {
    testWidgets('renderiza header Populares y tarjetas', (tester) async {
      final books = [
        createTestBook(id: 1, name: 'Popular A'),
        createTestBook(id: 2, name: 'Popular B'),
      ];

      await tester.pumpWidget(wrapWithMaterial(
        SectionPopulares(
          books: books,
          onBookTap: (_) {},
        ),
      ));

      expect(find.text('Populares'), findsOneWidget);
      expect(find.text('Popular A'), findsOneWidget);
      expect(find.text('Popular B'), findsOneWidget);
    });

    testWidgets('vacío retorna SizedBox.shrink', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SectionPopulares(
          books: [],
          onBookTap: (_) {},
        ),
      ));

      expect(find.text('Populares'), findsNothing);
    });

    testWidgets('tap en card invoca onBookTap', (tester) async {
      final books = [createTestBook(id: 1, name: 'Tap Book')];
      BookWithRelations? tapped;

      await tester.pumpWidget(wrapWithMaterial(
        SectionPopulares(
          books: books,
          onBookTap: (book) => tapped = book,
        ),
      ));

      await tester.tap(find.text('Tap Book'));
      expect(tapped, isNotNull);
      expect(tapped!.name, 'Tap Book');
    });
  });
}
