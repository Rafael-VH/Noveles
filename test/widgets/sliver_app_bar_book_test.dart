import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/books/presentation/screens/widgets/sliver_app_bar_book.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    setupCoverUrlService();
  });

  group('SliverAppBarBook', () {
    testWidgets('collapsed title muestra book.name', (tester) async {
      final book = createTestBook(name: 'El Principito');

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBarBook(books: book),
              SliverToBoxAdapter(child: SizedBox(height: 1000)),
            ],
          ),
        ),
      ));
      await tester.pump();

      // El collapsed title debe ser el nombre del libro
      expect(find.text('El Principito'), findsWidgets);
    });

    testWidgets('blur overlay presente (BackdropFilter)', (tester) async {
      final book = createTestBook();

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBarBook(books: book),
              SliverToBoxAdapter(child: SizedBox(height: 1000)),
            ],
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stretch mode activo', (tester) async {
      final book = createTestBook();

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBarBook(books: book),
              SliverToBoxAdapter(child: SizedBox(height: 1000)),
            ],
          ),
        ),
      ));
      await tester.pump();

      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.stretch, isTrue);
    });
  });
}
