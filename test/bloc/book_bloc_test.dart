import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/get_book_by_id.dart';
import 'package:noveles/features/books/presentation/bloc/book_bloc.dart';
import 'package:noveles/features/books/presentation/bloc/book_event.dart';
import 'package:noveles/features/books/presentation/bloc/book_state.dart';

class MockGetBooks extends Mock implements GetBooks {}

class MockGetBookById extends Mock implements GetBookById {}

void main() {
  late MockGetBooks mockGetBooks;
  late MockGetBookById mockGetBookById;
  late BookBloc bookBloc;

  setUp(() {
    mockGetBooks = MockGetBooks();
    mockGetBookById = MockGetBookById();
    bookBloc = BookBloc(
      getBooks: mockGetBooks,
      getBookById: mockGetBookById,
    );
  });

  tearDown(() {
    bookBloc.close();
  });

  group('BookBloc', () {
    final testBooks = [
      BookWithRelations(
        id: 1,
        createdAt: DateTime(2024),
        cover: 'cover1.jpg',
        name: 'Test Book',
        short: 'Short description',
        alternative: '',
        description: 'Full description',
        authorId: 1,
        author: 'Test Author',
        country: 'JP',
        state: 'ongoing',
        type: 'novel',
        release: '2024',
        tookCount: 5,
        chapterCount: 50,
        source: 'source',
        link: '',
        isFavorite: false,
        isVisible: true,
        listGenreIds: const [],
        listTookIds: const [],
        listLabelIds: const [],
      ),
    ];

    test('initial state is BookInitial', () {
      expect(bookBloc.state, equals(BookInitial()));
    });

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BookLoaded] when LoadBooks is added',
      build: () {
        when(() => mockGetBooks(
          onlyVisible: any(named: 'onlyVisible'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Ok(testBooks));
        return bookBloc;
      },
      act: (bloc) => bloc.add(LoadBooks()),
      expect: () => [
        isA<BookLoading>(),
        isA<BookLoaded>().having((s) => s.books, 'books', testBooks),
      ],
    );

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BookError] when GetBooks fails',
      build: () {
        when(() => mockGetBooks(
          onlyVisible: any(named: 'onlyVisible'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Err(BookFailure('API error')));
        return bookBloc;
      },
      act: (bloc) => bloc.add(LoadBooks()),
      expect: () => [
        isA<BookLoading>(),
        isA<BookError>()
            .having((s) => s.message, 'message', contains('API error')),
      ],
    );

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BookDetailLoaded] when LoadBookById succeeds',
      build: () {
        when(() => mockGetBookById(1))
            .thenAnswer((_) async => Ok(testBooks.first));
        return bookBloc;
      },
      act: (bloc) => bloc.add(LoadBookById(1)),
      expect: () => [
        isA<BookLoading>(),
        isA<BookDetailLoaded>().having((s) => s.book.id, 'id', 1),
      ],
    );

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BookError] when book is null',
      build: () {
        when(() => mockGetBookById(999))
            .thenAnswer((_) async => Ok<BookWithRelations?>(null));
        return bookBloc;
      },
      act: (bloc) => bloc.add(LoadBookById(999)),
      expect: () => [
        isA<BookLoading>(),
        isA<BookError>()
            .having((s) => s.message, 'message', 'Libro no encontrado'),
      ],
    );

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BookError] when GetBookById fails',
      build: () {
        when(() => mockGetBookById(999))
            .thenAnswer((_) async => Err(BookFailure('Server error')));
        return bookBloc;
      },
      act: (bloc) => bloc.add(LoadBookById(999)),
      expect: () => [
        isA<BookLoading>(),
        isA<BookError>()
            .having((s) => s.message, 'message', contains('Server error')),
      ],
    );

    // --- Pagination tests ---

    blocTest<BookBloc, BookState>(
      'LoadBooks sets hasMore to false when result is shorter than pageSize',
      build: () {
        when(() => mockGetBooks(
          onlyVisible: any(named: 'onlyVisible'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Ok(testBooks));
        return bookBloc;
      },
      act: (bloc) => bloc.add(LoadBooks()),
      expect: () => [
        isA<BookLoading>(),
        isA<BookLoaded>().having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    final secondBook = BookWithRelations(
      id: 2,
      createdAt: DateTime(2024),
      cover: 'cover2.jpg',
      name: 'Second Book',
      short: 'Short',
      alternative: '',
      description: 'Desc',
      authorId: 1,
      author: 'Author',
      country: 'KR',
      state: 'completed',
      type: 'novel',
      release: '2024',
      tookCount: 10,
      chapterCount: 100,
      source: 'src',
      link: '',
      isFavorite: false,
      isVisible: true,
      listGenreIds: const [],
      listTookIds: const [],
      listLabelIds: const [],
    );

    blocTest<BookBloc, BookState>(
      'LoadMoreBooks appends new books to existing list',
      build: () {
        when(() => mockGetBooks(
          onlyVisible: any(named: 'onlyVisible'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((invocation) async {
          final page = invocation.namedArguments[#page] as int;
          if (page == 2) return Ok([secondBook]);
          return Ok(testBooks);
        });
        return bookBloc;
      },
      act: (bloc) {
        bloc.add(LoadBooks());
        bloc.add(const LoadMoreBooks(2));
      },
      verify: (bloc) {
        final loaded = bloc.state as BookLoaded;
        expect(loaded.books.length, 2);
        expect(loaded.books.first.name, 'Test Book');
        expect(loaded.books.last.name, 'Second Book');
        expect(loaded.hasMore, isFalse);
      },
    );

    blocTest<BookBloc, BookState>(
      'LoadMoreBooks does nothing when state is not BookLoaded',
      build: () {
        return bookBloc;
      },
      act: (bloc) => bloc.add(const LoadMoreBooks(2)),
      expect: () => <BookState>[],
    );
  });
}
