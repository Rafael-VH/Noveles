import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/book_card_vertical.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    setupCoverUrlService();
  });

  group('BookCardVertical', () {
    testWidgets('renderiza nombre y autor', (tester) async {
      final book = createTestBook(
        name: 'El Principito',
        author: 'Saint-Exupéry',
      );

      await tester.pumpWidget(wrapWithMaterial(
        BookCardVertical(
          book: book,
          onTap: () {},
        ),
      ));

      expect(find.text('El Principito'), findsOneWidget);
      expect(find.text('Saint-Exupéry'), findsOneWidget);
    });

    testWidgets('tap invoca onTap', (tester) async {
      final book = createTestBook();
      bool tapped = false;

      await tester.pumpWidget(wrapWithMaterial(
        BookCardVertical(
          book: book,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('nombre largo se trunca con ellipsis', (tester) async {
      final longName = 'A' * 100;
      final book = createTestBook(name: longName);

      await tester.pumpWidget(wrapWithMaterial(
        BookCardVertical(
          book: book,
          onTap: () {},
        ),
      ));

      final textWidget = tester.widget<Text>(find.text(longName));
      expect(textWidget.maxLines, equals(2));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('es StatefulWidget con AnimatedScale', (tester) async {
      final book = createTestBook();
      bool tapped = false;

      await tester.pumpWidget(wrapWithMaterial(
        BookCardVertical(
          book: book,
          onTap: () => tapped = true,
        ),
      ));

      // Verify AnimatedScale exists
      expect(find.byType(AnimatedScale), findsOneWidget);
    });
  });
}
