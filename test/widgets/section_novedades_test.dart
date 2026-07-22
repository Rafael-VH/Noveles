import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/section_novedades.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    setupCoverUrlService();
  });

  group('SectionNovedades', () {
    testWidgets('renderiza header Novedades y libros', (tester) async {
      final books = [
        createTestBook(id: 1, name: 'Libro A'),
        createTestBook(id: 2, name: 'Libro B'),
      ];

      await tester.pumpWidget(wrapWithMaterial(
        SectionNovedades(
          books: books,
          onBookTap: (_) {},
        ),
      ));

      expect(find.text('Novedades'), findsOneWidget);
      expect(find.text('Libro A'), findsOneWidget);
      expect(find.text('Libro B'), findsOneWidget);
    });

    testWidgets('vacío retorna SizedBox.shrink', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        SectionNovedades(
          books: [],
          onBookTap: (_) {},
        ),
      ));

      // Should not render header when empty
      expect(find.text('Novedades'), findsNothing);
    });

    testWidgets('tap en card invoca onBookTap', (tester) async {
      final books = [createTestBook(id: 1, name: 'Tap Book')];
      BookWithRelations? tapped;

      await tester.pumpWidget(wrapWithMaterial(
        SectionNovedades(
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
