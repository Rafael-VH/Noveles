import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/book_card_horizontal.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    setupCoverUrlService();
  });

  group('BookCardHorizontal', () {
    testWidgets('renderiza nombre, autor y tomos', (tester) async {
      final book = createTestBook(
        name: 'Cien Años',
        author: 'García Márquez',
        tookCount: 3,
      );

      await tester.pumpWidget(wrapWithMaterial(
        BookCardHorizontal(
          book: book,
          onTap: () {},
        ),
      ));

      expect(find.text('Cien Años'), findsOneWidget);
      expect(find.text('García Márquez'), findsOneWidget);
      expect(find.text('3 tomos'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('tiene altura fija de 120 via SizedBox', (tester) async {
      final book = createTestBook();

      await tester.pumpWidget(wrapWithMaterial(
        BookCardHorizontal(
          book: book,
          onTap: () {},
        ),
      ));

      // Find the SizedBox inside the card — should have height 120
      final sizedBoxes =
          tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      final hasHeight120 = sizedBoxes.any((s) => s.height == 120);
      expect(hasHeight120, isTrue,
          reason: 'BookCardHorizontal debe tener un SizedBox con height 120');
    });

    testWidgets('tap invoca onTap', (tester) async {
      final book = createTestBook();
      bool tapped = false;

      await tester.pumpWidget(wrapWithMaterial(
        BookCardHorizontal(
          book: book,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
