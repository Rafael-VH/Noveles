import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_detail_content.dart';
import 'package:noveles/features/books/presentation/screens/widgets/card_info_detail.dart';
import 'package:noveles/features/app/presentation/widgets/genre_chip_styled.dart';
import 'package:noveles/features/app/presentation/widgets/section_title.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockFavoriteBloc extends Mock implements FavoriteBloc {}

void main() {
  late MockAuthBloc authBloc;
  late MockFavoriteBloc favoriteBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthUnauthenticated());
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

    favoriteBloc = MockFavoriteBloc();
    when(() => favoriteBloc.state).thenReturn(FavoriteInitial());
    when(() => favoriteBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestWidget(BookWithRelations book) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<FavoriteBloc>.value(value: favoriteBloc),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BookDetailContent(books: book),
          ),
        ),
      ),
    );
  }

  /// Scroll down enough to make the widget content visible
  /// (avoids CustomScrollView/Viewport null-check issues in tests).
  // ignore: unused_element
  Future<void> pumpScrolled(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pump();
    // Scroll to reveal all content
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pump();
  }

  final baseBook = BookWithRelations(
    id: 1,
    createdAt: DateTime(2026),
    cover: 'cover.jpg',
    name: 'Test Book',
    short: 'Test',
    alternative: '',
    description: 'Una descripción de prueba para el libro',
    authorId: 1,
    author: 'Autor',
    country: 'Argentina',
    state: 'Activo',
    type: 'Novela',
    release: '2026',
    tookCount: 5,
    chapterCount: 50,
    source: '',
    link: '',
    isFavorite: false,
    isVisible: true,
    listGenreIds: const [],
    listTookIds: const [],
    listLabelIds: const [],
    createdBy: null,
    listGenre: [
      GenreEntity(id: 1, createdAt: DateTime(2026), name: 'Fantasía', description: ''),
      GenreEntity(id: 2, createdAt: DateTime(2026), name: 'Aventura', description: ''),
    ],
    listTook: const [],
    listLabel: const [],
  );

  group('BookDetailContent', () {
    testWidgets('renderiza descripción y tarjetas de info', (tester) async {
      await tester.pumpWidget(buildTestWidget(baseBook));

      expect(find.text('Descripción'), findsOneWidget);
      expect(find.text('Una descripción de prueba para el libro'), findsOneWidget);
      expect(find.text('PUBLICADO'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('TIPO DE NOVELA'), findsOneWidget);
      expect(find.text('Novela'), findsOneWidget);
      expect(find.text('PAÍS'), findsOneWidget);
      expect(find.text('Argentina'), findsOneWidget);
      expect(find.text('ESTADO'), findsOneWidget);
      expect(find.text('Activo'), findsOneWidget);
      expect(find.text('TOMOS'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('CAPÍTULOS'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      // Solo 1 CardInfoDetail ahora (6 pares fusionados)
      expect(find.byType(CardInfoDetail), findsOneWidget);
    });

    testWidgets('usa SectionTitle con showAccent para headers', (tester) async {
      await tester.pumpWidget(buildTestWidget(baseBook));

      expect(find.byType(SectionTitle), findsAtLeast(1));
    });

    testWidgets('renderiza géneros como GenreChipStyled', (tester) async {
      await tester.pumpWidget(buildTestWidget(baseBook));

      expect(find.text('Generos'), findsOneWidget);
      expect(find.text('Fantasía'), findsOneWidget);
      expect(find.text('Aventura'), findsOneWidget);

      // Verifica que usa GenreChipStyled en vez de Chip crudo
      expect(find.byType(GenreChipStyled), findsAtLeast(1));
    });

    testWidgets('muestra FavoriteButton', (tester) async {
      await tester.pumpWidget(buildTestWidget(baseBook));

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('sección de fuente no aparece cuando source y link están vacíos', (tester) async {
      await tester.pumpWidget(buildTestWidget(baseBook));

      expect(find.text('Fuente'), findsNothing);
    });

    testWidgets('sección de fuente aparece cuando source no está vacío', (tester) async {
      final bookWithSource = baseBook.copyWith(
        source: 'Web Novel',
        link: '',
      );

      await tester.pumpWidget(buildTestWidget(bookWithSource));

      // SectionTitle "Fuente" + CardInfoDetail pair title "FUENTE"
      expect(find.text('Fuente'), findsOneWidget);
      expect(find.text('FUENTE'), findsOneWidget);
      expect(find.text('Web Novel'), findsOneWidget);
    });

    testWidgets('sección de fuente aparece cuando link no está vacío', (tester) async {
      final bookWithLink = baseBook.copyWith(
        source: '',
        link: 'https://example.com/book',
      );

      await tester.pumpWidget(buildTestWidget(bookWithLink));

      // SectionTitle "Fuente" + CardInfoDetail pair title "FUENTE"
      expect(find.text('Fuente'), findsOneWidget);
      expect(find.text('FUENTE'), findsOneWidget);
      expect(find.text('https://example.com/book'), findsOneWidget);
    });

    testWidgets('muestra enlace clickeable cuando link no está vacío', (tester) async {
      final bookWithLink = baseBook.copyWith(
        source: 'Web',
        link: 'https://example.com/book',
      );

      await tester.pumpWidget(buildTestWidget(bookWithLink));

      expect(find.text('Abrir enlace'), findsOneWidget);
    });
  });
}
