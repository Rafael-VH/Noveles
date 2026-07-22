import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/app/presentation/widgets/section_header.dart';
import 'package:noveles/features/app/presentation/widgets/section_novedades.dart';
import 'package:noveles/features/app/presentation/widgets/section_populares.dart';
import 'package:noveles/features/app/presentation/widgets/genre_chip_styled.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    setupCoverUrlService();
  });

  group('MainScreen integración de secciones', () {
    testWidgets('Novedades + Populares + Géneros se renderizan juntos',
        (tester) async {
      final books = List.generate(8, (i) => createTestBook(
        id: i + 1,
        name: 'Book $i',
        createdAt: DateTime(2026, 1, i + 1),
        tookCount: 10 - i,
      ));
      final genres = [
        GenreEntity(id: 1, createdAt: DateTime(2026), name: 'Aventura', description: ''),
        GenreEntity(id: 2, createdAt: DateTime(2026), name: 'Romance', description: ''),
      ];

      await tester.pumpWidget(wrapWithMaterial(
        SingleChildScrollView(
          child: Column(
            children: [
              SectionNovedades(
                books: books.take(6).toList(),
                onBookTap: (_) {},
              ),
              SectionPopulares(
                books: books.take(6).toList(),
                onBookTap: (_) {},
              ),
              const SectionHeader(title: 'Géneros', icon: Icons.category),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: genres
                      .map((g) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GenreChipStyled(
                              genre: g,
                              onTap: () {},
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      // Verify all sections render
      expect(find.text('Novedades'), findsOneWidget);
      expect(find.text('Populares'), findsOneWidget);
      expect(find.text('Géneros'), findsOneWidget);
      expect(find.text('Aventura'), findsOneWidget);
      expect(find.text('Romance'), findsOneWidget);
    });

    testWidgets('sortedNovedades ordena por createdAt DESC y toma 6',
        (tester) async {
      final books = List.generate(8, (i) => createTestBook(
        id: i + 1,
        name: 'Book ${i + 1}',
        createdAt: DateTime(2026, 6, i + 1),
      ));

      final sorted = List<BookWithRelations>.from(books)
        ..sort((a, b) {
          final c = b.createdAt.compareTo(a.createdAt);
          return c != 0 ? c : b.id.compareTo(a.id);
        });
      final top6 = sorted.take(6).toList();

      expect(top6.length, 6);
      // Most recent first (June 8, June 7, ..., June 3)
      expect(top6[0].name, 'Book 8');
      expect(top6[1].name, 'Book 7');
      expect(top6[5].name, 'Book 3');
    });

    testWidgets('sortedPopulares ordena por tookCount DESC y toma 6',
        (tester) async {
      final books = List.generate(8, (i) => createTestBook(
        id: i + 1,
        name: 'Book ${i + 1}',
        tookCount: i, // Book1=0, Book2=1, ..., Book8=7
      ));

      final sorted = List<BookWithRelations>.from(books)
        ..sort((a, b) {
          final tookComp = b.tookCount.compareTo(a.tookCount);
          if (tookComp != 0) return tookComp;
          return b.chapterCount.compareTo(a.chapterCount);
        });
      final top6 = sorted.take(6).toList();

      expect(top6.length, 6);
      // Highest tookCount first (Book8=7, Book7=6, ..., Book3=2)
      expect(top6[0].name, 'Book 8');
      expect(top6[1].name, 'Book 7');
      expect(top6[5].name, 'Book 3');
    });
  });
}
