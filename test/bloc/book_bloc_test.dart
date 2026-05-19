import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/book/book_bloc.dart';
import 'package:noveles/features/presentation/bloc/book/book_event.dart';
import 'package:noveles/features/presentation/bloc/book/book_state.dart';

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
      BookEntity(
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
        tookCount: '5',
        chapterCount: '50',
        source: 'source',
        link: '',
        isFavorite: false,
        isVisible: true,
        listGenre: const [],
        listTook: const [], listLabel: const [],
      ),
    ];

    test('initial state is BookInitial', () {
      expect(bookBloc.state, equals(BookInitial()));
    });

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BookLoaded] when LoadBooks is added',
      build: () {
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
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
        when(() => mockGetBooks()).thenThrow(Exception('API error'));
        return bookBloc;
      },
      act: (bloc) => bloc.add(LoadBooks()),
      expect: () => [
        isA<BookLoading>(),
        isA<BookError>().having((s) => s.message, 'message', contains('API error')),
      ],
    );

    blocTest<BookBloc, BookState>(
      'emits [BookLoading, BookDetailLoaded] when LoadBookById succeeds',
      build: () {
        when(() => mockGetBookById(1)).thenAnswer((_) async => testBooks.first);
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
        when(() => mockGetBookById(999)).thenAnswer((_) async => null);
        return bookBloc;
      },
      act: (bloc) => bloc.add(LoadBookById(999)),
      expect: () => [
        isA<BookLoading>(),
        isA<BookError>().having((s) => s.message, 'message', 'Libro no encontrado'),
      ],
    );
  });
}
