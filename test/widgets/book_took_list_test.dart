import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_took_list.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

void main() {
  final tooks = [
    TookEntity(
      id: 1,
      createdAt: DateTime(2026),
      cover: 'cover1.jpg',
      number: 'Vol. 1',
      title: 'El comienzo',
      chapterCount: 10,
      bookId: 1,
      listChapterIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    ),
    TookEntity(
      id: 2,
      createdAt: DateTime(2026),
      cover: 'cover2.jpg',
      number: 'Vol. 2',
      title: 'El desarrollo',
      chapterCount: 8,
      bookId: 1,
      listChapterIds: [11, 12, 13, 14, 15, 16, 17, 18],
    ),
    TookEntity(
      id: 3,
      createdAt: DateTime(2026),
      cover: 'cover3.jpg',
      number: 'Vol. 3',
      title: 'El desenlace',
      chapterCount: 12,
      bookId: 1,
      listChapterIds: [19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
    ),
  ];

  Widget buildTestWidget({
    required List<TookEntity> tooks,
    required void Function(TookEntity) onTookTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BookTookList(
          tooks: tooks,
          onTookTap: onTookTap,
        ),
      ),
    );
  }

  group('BookTookList', () {
    testWidgets('renderiza la cantidad correcta de items', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(tooks: tooks, onTookTap: (_) {}),
      );

      expect(find.text('Vol. 1'), findsOneWidget);
      expect(find.text('Vol. 2'), findsOneWidget);
      expect(find.text('Vol. 3'), findsOneWidget);
    });

    testWidgets('muestra número, título y cantidad de capítulos', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(tooks: tooks, onTookTap: (_) {}),
      );

      expect(find.text('El comienzo'), findsOneWidget);
      expect(find.text('El desarrollo'), findsOneWidget);
      expect(find.text('El desenlace'), findsOneWidget);

      expect(find.text('10'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('onTookTap se llama al hacer tap en un item', (tester) async {
      TookEntity? tappedTook;

      await tester.pumpWidget(
        buildTestWidget(
          tooks: tooks,
          onTookTap: (took) => tappedTook = took,
        ),
      );

      await tester.tap(find.text('Vol. 2'));
      expect(tappedTook, isNotNull);
      expect(tappedTook!.id, 2);
      expect(tappedTook!.number, 'Vol. 2');
    });

    testWidgets('renderiza lista vacía sin errores', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(tooks: [], onTookTap: (_) {}),
      );

      expect(find.byType(Card), findsNothing);
    });
  });
}
