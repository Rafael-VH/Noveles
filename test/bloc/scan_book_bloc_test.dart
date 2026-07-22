import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/create_book.dart';
import 'package:noveles/features/books/domain/update_book.dart';
import 'package:noveles/features/books/domain/delete_book.dart';
import 'package:noveles/features/books/domain/toggle_book_visibility.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_book_bloc.dart';

class MockGetBooks extends Mock implements GetBooks {}

class MockCreateBook extends Mock implements CreateBook {}

class MockUpdateBook extends Mock implements UpdateBook {}

class MockDeleteBook extends Mock implements DeleteBook {}

class MockToggleBookVisibility extends Mock implements ToggleBookVisibility {}

void main() {
  late MockGetBooks mockGetBooks;
  late MockCreateBook mockCreateBook;
  late MockUpdateBook mockUpdateBook;
  late MockDeleteBook mockDeleteBook;
  late MockToggleBookVisibility mockToggleVisibility;
  late ScanBookBloc scanBookBloc;

  final testBooks = [
    BookWithRelations(
      id: 1,
      createdAt: DateTime(2024),
      cover: 'cover.png',
      name: 'Test Book',
      short: '',
      alternative: '',
      description: '',
      authorId: 1,
      author: 'Author',
      country: 'JP',
      state: 'ongoing',
      type: 'novel',
      release: '2024',
      tookCount: 1,
      chapterCount: 10,
      source: '',
      link: '',
      isFavorite: false,
      isVisible: true,
      listGenreIds: const [],
      listTookIds: const [],
      listLabelIds: const [],
    ),
  ];

  setUpAll(() {
    registerFallbackValue(BookWithRelations(
      id: 0,
      createdAt: DateTime(2024),
      cover: '',
      name: '',
      short: '',
      alternative: '',
      description: '',
      authorId: 0,
      author: '',
      country: '',
      state: '',
      type: '',
      release: '',
      tookCount: 0,
      chapterCount: 0,
      source: '',
      link: '',
      isFavorite: false,
      isVisible: true,
      listGenreIds: const [],
      listTookIds: const [],
      listLabelIds: const [],
    ));
  });

  setUp(() {
    mockGetBooks = MockGetBooks();
    mockCreateBook = MockCreateBook();
    mockUpdateBook = MockUpdateBook();
    mockDeleteBook = MockDeleteBook();
    mockToggleVisibility = MockToggleBookVisibility();
    scanBookBloc = ScanBookBloc(
      getBooks: mockGetBooks,
      createBook: mockCreateBook,
      updateBook: mockUpdateBook,
      deleteBook: mockDeleteBook,
      toggleBookVisibility: mockToggleVisibility,
    );
  });

  tearDown(() {
    scanBookBloc.close();
  });

  group('ScanBookBloc', () {
    test('initial state is ScanBookInitial', () {
      expect(scanBookBloc.state, equals(ScanBookInitial()));
    });

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookLoading, ScanBookLoaded] when LoadScanBooks succeeds',
      build: () {
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(LoadScanBooks()),
      expect: () => [
        isA<ScanBookLoading>(),
        isA<ScanBookLoaded>().having((s) => s.books, 'books', testBooks),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookLoading, ScanBookError] when LoadScanBooks fails',
      build: () {
        when(() => mockGetBooks())
            .thenAnswer((_) async => Err(BookFailure('Error de red')));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(LoadScanBooks()),
      expect: () => [
        isA<ScanBookLoading>(),
        isA<ScanBookError>()
            .having((s) => s.message, 'message', contains('Error de red')),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookLoaded] when SaveScanBook succeeds',
      build: () {
        when(() => mockUpdateBook(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: true)),
      expect: () => [
        isA<ScanBookLoaded>()
            .having((s) => s.message, 'message', 'Libro guardado'),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookError] when DeleteScanBook fails',
      build: () {
        when(() => mockDeleteBook(any()))
            .thenAnswer((_) async => Err(BookFailure('Error')));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(DeleteScanBook(999)),
      expect: () => [
        isA<ScanBookError>(),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookLoaded] when DeleteScanBook succeeds',
      build: () {
        when(() => mockDeleteBook(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(DeleteScanBook(1)),
      expect: () => [
        isA<ScanBookLoaded>()
            .having((s) => s.message, 'message', 'Libro eliminado'),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookLoaded] when SaveScanBook creates new book',
      build: () {
        when(() => mockCreateBook(any()))
            .thenAnswer((_) async => const Ok(1));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: false)),
      expect: () => [
        isA<ScanBookLoaded>()
            .having((s) => s.message, 'message', 'Libro creado'),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookError] when SaveScanBook create fails',
      build: () {
        when(() => mockCreateBook(any()))
            .thenAnswer((_) async => Err(BookFailure('Error al crear')));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: false)),
      expect: () => [
        isA<ScanBookError>()
            .having((s) => s.message, 'message', contains('Error al crear')),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookError] when SaveScanBook update fails',
      build: () {
        when(() => mockUpdateBook(any()))
            .thenAnswer((_) async => Err(BookFailure('Error al actualizar')));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: true)),
      expect: () => [
        isA<ScanBookError>().having(
          (s) => s.message,
          'message',
          contains('Error al actualizar'),
        ),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookLoaded] when ToggleScanBookVisibility hides',
      build: () {
        when(() => mockToggleVisibility(any(), any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(ToggleScanBookVisibility(1, false)),
      expect: () => [
        isA<ScanBookLoaded>()
            .having((s) => s.message, 'message', 'Novela oculta'),
      ],
    );

    blocTest<ScanBookBloc, ScanBookState>(
      'emits [ScanBookError] when ToggleScanBookVisibility fails',
      build: () {
        when(() => mockToggleVisibility(any(), any()))
            .thenAnswer((_) async => Err(BookFailure('Error')));
        return scanBookBloc;
      },
      act: (bloc) => bloc.add(ToggleScanBookVisibility(1, true)),
      expect: () => [
        isA<ScanBookError>(),
      ],
    );

    // --- P1: refresh fallback when getBooks fails after successful save ---

    blocTest<ScanBookBloc, ScanBookState>(
      'SaveScanBook falls back to previous books when refresh fails',
      build: () {
        // First call: load books successfully
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        when(() => mockUpdateBook(any()))
            .thenAnswer((_) async => const Ok(null));
        return scanBookBloc;
      },
      act: (bloc) async {
        bloc.add(LoadScanBooks());
        await Future<void>.delayed(Duration.zero);
        // Second call: refresh fails after save
        when(() => mockGetBooks())
            .thenAnswer((_) async => Err(BookFailure('Network')));
        bloc.add(SaveScanBook(testBooks.first, isUpdate: true));
      },
      expect: () => [
        isA<ScanBookLoading>(),
        isA<ScanBookLoaded>(),
        // Save succeeds but refresh fails → fallback with previous books
        isA<ScanBookLoaded>()
            .having((s) => s.books.length, 'previous books count', 1)
            .having(
              (s) => s.message,
              'message',
              contains('Error al refrescar'),
            ),
      ],
    );
  });
}
