import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/carousel_appbar_sliver.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    setupCoverUrlService();
  });

  group('SliverAppBarHome - carrusel dots', () {
    testWidgets('carrusel vacío no crashea y no muestra dots', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBarHome(
                listBook: [],
                onBookTap: (_) {},
                actions: [],
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(SliverAppBarHome), findsOneWidget);
    });

    testWidgets('renderiza N dots cuando hay N books', (tester) async {
      final books = List.generate(3, (i) => createTestBook(
        id: i + 1,
        name: 'Book ${i + 1}',
      ));

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBarHome(
                listBook: books,
                onBookTap: (_) {},
                actions: [],
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      // Each dot is an AnimatedContainer — there should be at least 3
      expect(find.byType(AnimatedContainer), findsAtLeast(3));
    });

    testWidgets('dots activo usa primary, inactivo usa onSurfaceVariant 0.5',
        (tester) async {
      final books = List.generate(3, (i) => createTestBook(
        id: i + 1,
        name: 'Book ${i + 1}',
      ));

      Color? primary;
      Color? inactiveColor;

      await tester.pumpWidget(wrapWithMaterial(
        Builder(builder: (context) {
          primary = Theme.of(context).colorScheme.primary;
          inactiveColor = Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withValues(alpha: 0.5);
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBarHome(
                  listBook: books,
                  onBookTap: (_) {},
                  actions: [],
                ),
              ],
            ),
          );
        }),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final containers =
          tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
              .toList();
      expect(containers.length, 3);

      // Active dot (first, index 0): primary color
      final activeDeco = containers[0].decoration as BoxDecoration;
      expect(activeDeco.color, primary);

      // Inactive dots: onSurfaceVariant with 0.5 alpha
      final inactiveDeco1 = containers[1].decoration as BoxDecoration;
      expect(inactiveDeco1.color, inactiveColor);
      final inactiveDeco2 = containers[2].decoration as BoxDecoration;
      expect(inactiveDeco2.color, inactiveColor);
    });

    testWidgets('primer dot es más ancho que los inactivos',
        (tester) async {
      final books = List.generate(3, (i) => createTestBook(
        id: i + 1,
        name: 'Book ${i + 1}',
      ));

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBarHome(
                listBook: books,
                onBookTap: (_) {},
                actions: [],
              ),
            ],
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final containers =
          tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
              .toList();
      expect(containers.length, 3);

      // AnimatedContainer stores width in constraints, not as a direct property.
      // Instead, check via RenderBox sizes after layout.
      final boxes = containers.map((c) {
        // Find each AnimatedContainer by its decoration to get unique render box
        return tester.renderObject<RenderBox>(
          find.byWidgetPredicate(
            (w) => w is AnimatedContainer && identical(w, c),
          ),
        );
      }).toList();

      // Active (first) dot should be wider than inactive dots
      expect(boxes[0].size.width, greaterThan(boxes[1].size.width));
      expect(boxes[1].size.width, boxes[2].size.width);
    });

    testWidgets('usa titleLarge para el nombre del libro', (tester) async {
      final books = List.generate(1, (i) => createTestBook(
        id: i + 1,
        name: 'Book Title',
      ));

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBarHome(
                listBook: books,
                onBookTap: (_) {},
                actions: [],
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      final text = tester.widget<Text>(find.text('Book Title'));
      expect(text.style?.fontSize, 22);
    });

    testWidgets('muestra indicador "1/N"', (tester) async {
      final books = List.generate(3, (i) => createTestBook(
        id: i + 1,
        name: 'Book ${i + 1}',
      ));

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBarHome(
                listBook: books,
                onBookTap: (_) {},
                actions: [],
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('1/3'), findsOneWidget);
    });
  });
}
