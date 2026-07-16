import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/books/domain/book_with_relations.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/create_book.dart';
import 'package:noveles/features/books/domain/update_book.dart';
import 'package:noveles/features/books/domain/delete_book.dart';
import 'package:noveles/features/books/domain/upload_cover.dart';
import 'package:noveles/features/books/domain/toggle_book_visibility.dart';
import 'package:noveles/features/genres/domain/get_genre.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_event.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_state.dart';

class MockGetBooks extends Mock implements GetBooks {}

class MockCreateBook extends Mock implements CreateBook {}

class MockUpdateBook extends Mock implements UpdateBook {}

class MockDeleteBook extends Mock implements DeleteBook {}

class MockGetGenre extends Mock implements GetGenre {}

class MockUploadCover extends Mock implements UploadCover {}

class MockToggleBookVisibility extends Mock implements ToggleBookVisibility {}

void main() {
  late MockGetBooks mockGetBooks;
  late MockCreateBook mockCreateBook;
  late MockUpdateBook mockUpdateBook;
  late MockDeleteBook mockDeleteBook;
  late MockGetGenre mockGetGenre;
  late MockUploadCover mockUploadCover;
  late MockToggleBookVisibility mockToggleVisibility;
  late ScanBloc scanBloc;

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
    registerFallbackValue(GenreEntity(
      id: 0,
      createdAt: DateTime(2024),
      name: '',
      description: '',
    ));
  });

  setUp(() {
    mockGetBooks = MockGetBooks();
    mockCreateBook = MockCreateBook();
    mockUpdateBook = MockUpdateBook();
    mockDeleteBook = MockDeleteBook();
    mockGetGenre = MockGetGenre();
    mockUploadCover = MockUploadCover();
    mockToggleVisibility = MockToggleBookVisibility();
    scanBloc = ScanBloc(
      getBooks: mockGetBooks,
      createBook: mockCreateBook,
      updateBook: mockUpdateBook,
      deleteBook: mockDeleteBook,
      getGenres: mockGetGenre,
      uploadCover: mockUploadCover,
      toggleBookVisibility: mockToggleVisibility,
    );
  });

  tearDown(() {
    scanBloc.close();
  });

  group('ScanBloc', () {
    test('initial state is ScanInitial', () {
      expect(scanBloc.state, equals(ScanInitial()));
    });

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when LoadScanBooks succeeds',
      build: () {
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBloc;
      },
      act: (bloc) => bloc.add(LoadScanBooks()),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.books, 'books', testBooks),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanError] when LoadScanBooks fails',
      build: () {
        when(() => mockGetBooks())
            .thenAnswer((_) async => Err(BookFailure('Error de red')));
        return scanBloc;
      },
      act: (bloc) => bloc.add(LoadScanBooks()),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanError>()
            .having((s) => s.message, 'message', contains('Error de red')),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits ScanGenresLoaded when LoadScanGenres succeeds',
      build: () {
        final genres = [
          GenreEntity(
              id: 1,
              createdAt: DateTime(2024),
              name: 'Acción',
              description: ''),
          GenreEntity(
              id: 2,
              createdAt: DateTime(2024),
              name: 'Romance',
              description: ''),
        ];
        when(() => mockGetGenre()).thenAnswer((_) async => Ok(genres));
        return scanBloc;
      },
      act: (bloc) => bloc.add(LoadScanGenres()),
      expect: () => [
        isA<ScanGenresLoaded>()
            .having((s) => s.genres.length, 'genre count', 2)
            .having((s) => s.genres.first.name, 'first genre name', 'Acción'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits ScanCoverUploaded when UploadScanCover succeeds',
      build: () {
        when(() => mockUploadCover(any()))
            .thenAnswer((_) async => Ok('uploaded_cover.png'));
        return scanBloc;
      },
      act: (bloc) => bloc.add(UploadScanCover('/path/to/cover.png')),
      expect: () => [
        isA<ScanCoverUploaded>().having(
          (s) => s.filename,
          'filename',
          'uploaded_cover.png',
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits ScanError when UploadScanCover fails',
      build: () {
        when(() => mockUploadCover(any()))
            .thenAnswer((_) async => Err(BookFailure('Error al subir')));
        return scanBloc;
      },
      act: (bloc) => bloc.add(UploadScanCover('/path/to/cover.png')),
      expect: () => [
        isA<ScanError>().having(
          (s) => s.message,
          'message',
          contains('Error al subir'),
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits ScanError when LoadScanGenres fails',
      build: () {
        when(() => mockGetGenre())
            .thenAnswer((_) async => Err(GenreFailure('Error de red')));
        return scanBloc;
      },
      act: (bloc) => bloc.add(LoadScanGenres()),
      expect: () => [
        isA<ScanError>().having(
          (s) => s.message,
          'message',
          contains('Error de red'),
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoaded] when SaveScanBook succeeds',
      build: () {
        when(() => mockUpdateBook(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: true)),
      expect: () => [
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Libro guardado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanError] when DeleteScanBook fails',
      build: () {
        when(() => mockDeleteBook(any()))
            .thenAnswer((_) async => Err(BookFailure('Error')));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBloc;
      },
      act: (bloc) => bloc.add(DeleteScanBook(999)),
      expect: () => [
        isA<ScanError>(),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoaded] when DeleteScanBook succeeds',
      build: () {
        when(() => mockDeleteBook(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBloc;
      },
      act: (bloc) => bloc.add(DeleteScanBook(1)),
      expect: () => [
        isA<ScanLoaded>()
            .having((s) => s.message, 'message', 'Libro eliminado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoaded] when SaveScanBook creates new book',
      build: () {
        when(() => mockCreateBook(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: false)),
      expect: () => [
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Libro creado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanError] when SaveScanBook create fails',
      build: () {
        when(() => mockCreateBook(any()))
            .thenAnswer((_) async => Err(BookFailure('Error al crear')));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: false)),
      expect: () => [
        isA<ScanError>()
            .having((s) => s.message, 'message', contains('Error al crear')),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanError] when SaveScanBook update fails',
      build: () {
        when(() => mockUpdateBook(any()))
            .thenAnswer((_) async => Err(BookFailure('Error al actualizar')));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: true)),
      expect: () => [
        isA<ScanError>().having(
          (s) => s.message,
          'message',
          contains('Error al actualizar'),
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoaded] when ToggleScanBookVisibility hides',
      build: () {
        when(() => mockToggleVisibility(any(), any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return scanBloc;
      },
      act: (bloc) => bloc.add(ToggleScanBookVisibility(1, false)),
      expect: () => [
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Novela oculta'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanError] when ToggleScanBookVisibility fails',
      build: () {
        when(() => mockToggleVisibility(any(), any()))
            .thenAnswer((_) async => Err(BookFailure('Error')));
        return scanBloc;
      },
      act: (bloc) => bloc.add(ToggleScanBookVisibility(1, true)),
      expect: () => [
        isA<ScanError>(),
      ],
    );
  });
}
