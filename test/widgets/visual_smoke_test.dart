import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_detail_content.dart';
import 'package:noveles/features/app/presentation/widgets/book_card_vertical.dart';
import 'package:noveles/features/app/presentation/widgets/book_card_horizontal.dart';
import 'package:noveles/features/app/presentation/widgets/carousel_appbar_sliver.dart';
import 'package:noveles/features/app/presentation/widgets/genre_chip_styled.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'test_helpers.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockFavoriteBloc extends Mock implements FavoriteBloc {}

void main() {
  late MockAuthBloc authBloc;
  late MockFavoriteBloc favoriteBloc;

  setUp(() {
    setupCoverUrlService();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthUnauthenticated());
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    favoriteBloc = MockFavoriteBloc();
    when(() => favoriteBloc.state).thenReturn(FavoriteInitial());
    when(() => favoriteBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  final testBook = BookWithRelations(
    id: 1,
    createdAt: DateTime(2026),
    cover: 'cover.jpg',
    name: 'Smoke Test Book',
    short: 'Smoke',
    alternative: '',
    description: 'Descripción de prueba para smoke test.',
    authorId: 1,
    author: 'Autor Smoke',
    country: 'Argentina',
    state: 'Activo',
    type: 'Novela',
    release: '2026',
    tookCount: 5,
    chapterCount: 50,
    source: 'Web',
    link: 'https://example.com',
    isFavorite: false,
    isVisible: true,
    listGenreIds: const [],
    listTookIds: const [],
    listLabelIds: const [],
    createdBy: null,
    listGenre: [
      GenreEntity(id: 1, createdAt: DateTime(2026), name: 'Fantasía', description: ''),
    ],
    listTook: const [],
    listLabel: const [],
  );

  group('Visual Smoke Tests', () {
    testWidgets('BookDetailContent no crashea en light theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF8F8FC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<FavoriteBloc>.value(value: favoriteBloc),
          ],
          child: Scaffold(
            body: SingleChildScrollView(
              child: BookDetailContent(books: testBook),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('Descripción'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Generos'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byType(GenreChipStyled), findsAtLeast(1));
    });

    testWidgets('BookDetailContent no crashea en dark theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF191A22),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<FavoriteBloc>.value(value: favoriteBloc),
          ],
          child: Scaffold(
            body: SingleChildScrollView(
              child: BookDetailContent(books: testBook),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('Descripción'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Generos'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('BookCardVertical y BookCardHorizontal no crashean', (tester) async {
      final book = createTestBook();

      await tester.pumpWidget(wrapWithMaterial(
        Column(
          children: [
            BookCardVertical(book: book, onTap: () {}),
            BookCardHorizontal(book: book, onTap: () {}),
          ],
        ),
      ));

      expect(find.byType(BookCardVertical), findsOneWidget);
      expect(find.byType(BookCardHorizontal), findsOneWidget);
      expect(find.byType(AnimatedScale), findsAtLeast(2));
    });

    testWidgets('CarouselAppBarSliver no crashea con datos', (tester) async {
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
      expect(find.byType(AnimatedContainer), findsAtLeast(3));
    });
  });
}
