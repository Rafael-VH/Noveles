import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_bloc.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_event.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_state.dart';

class MockGetBooks extends Mock implements GetBooks {}
class MockCreateBook extends Mock implements CreateBook {}
class MockUpdateBook extends Mock implements UpdateBook {}
class MockDeleteBook extends Mock implements DeleteBook {}
class MockCreateTook extends Mock implements CreateTook {}
class MockUpdateTook extends Mock implements UpdateTook {}
class MockDeleteTook extends Mock implements DeleteTook {}
class MockCreateChapter extends Mock implements CreateChapter {}
class MockUpdateChapter extends Mock implements UpdateChapter {}
class MockDeleteChapter extends Mock implements DeleteChapter {}
class MockGetGenre extends Mock implements GetGenre {}
class MockUploadCover extends Mock implements UploadCover {}

void main() {
  late MockGetBooks mockGetBooks;
  late MockCreateBook mockCreateBook;
  late MockUpdateBook mockUpdateBook;
  late MockDeleteBook mockDeleteBook;
  late MockCreateTook mockCreateTook;
  late MockUpdateTook mockUpdateTook;
  late MockDeleteTook mockDeleteTook;
  late MockCreateChapter mockCreateChapter;
  late MockUpdateChapter mockUpdateChapter;
  late MockDeleteChapter mockDeleteChapter;
  late MockGetGenre mockGetGenre;
  late MockUploadCover mockUploadCover;
  late ScanBloc scanBloc;

  final testBooks = [
    BookEntity(
      id: 1, createdAt: DateTime(2024), cover: 'cover.png',
      name: 'Test Book', short: '', alternative: '', description: '',
      authorId: 1, author: 'Author', country: 'JP', state: 'ongoing',
      type: 'novel', release: '2024', tookCount: '1', chapterCount: '10',
      source: '', link: '', isFavorite: false, listGenre: const [], listTook: const [],
    ),
  ];

  setUpAll(() {
    registerFallbackValue(BookEntity(
      id: 0, createdAt: DateTime(2024), cover: '',
      name: '', short: '', alternative: '', description: '',
      authorId: 0, author: '', country: '', state: '',
      type: '', release: '', tookCount: '', chapterCount: '',
      source: '', link: '', isFavorite: false, listGenre: const [], listTook: const [],
    ));
    registerFallbackValue(TookEntity(
      id: 0, createdAt: DateTime(2024), cover: '',
      number: '', title: '', chapterCount: '',
      bookId: 1, listChapter: const [],
    ));
    registerFallbackValue(ChapterEntity(
      id: 0, createdAt: DateTime(2024), number: '',
      title: '', content: '', tookId: 1,
    ));
    registerFallbackValue(GenreEntity(
      id: 0, createdAt: DateTime(2024), name: '', description: '',
    ));
  });

  setUp(() {
    mockGetBooks = MockGetBooks();
    mockCreateBook = MockCreateBook();
    mockUpdateBook = MockUpdateBook();
    mockDeleteBook = MockDeleteBook();
    mockCreateTook = MockCreateTook();
    mockUpdateTook = MockUpdateTook();
    mockDeleteTook = MockDeleteTook();
    mockCreateChapter = MockCreateChapter();
    mockUpdateChapter = MockUpdateChapter();
    mockDeleteChapter = MockDeleteChapter();
    mockGetGenre = MockGetGenre();
    mockUploadCover = MockUploadCover();
    scanBloc = ScanBloc(
      getBooks: mockGetBooks,
      createBook: mockCreateBook,
      updateBook: mockUpdateBook,
      deleteBook: mockDeleteBook,
      createTook: mockCreateTook,
      updateTook: mockUpdateTook,
      deleteTook: mockDeleteTook,
      createChapter: mockCreateChapter,
      updateChapter: mockUpdateChapter,
      deleteChapter: mockDeleteChapter,
      getGenres: mockGetGenre,
      uploadCover: mockUploadCover,
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
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
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
        when(() => mockGetBooks()).thenThrow(Exception('Error de red'));
        return scanBloc;
      },
      act: (bloc) => bloc.add(LoadScanBooks()),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanError>().having((s) => s.message, 'message', contains('Error de red')),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits ScanGenresLoaded when LoadScanGenres succeeds',
      build: () {
        final genres = [
          GenreEntity(id: 1, createdAt: DateTime(2024), name: 'Acción', description: ''),
          GenreEntity(id: 2, createdAt: DateTime(2024), name: 'Romance', description: ''),
        ];
        when(() => mockGetGenre()).thenAnswer((_) async => genres);
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
      'emits [ScanLoading, ScanLoaded] when SaveScanBook succeeds',
      build: () {
        when(() => mockUpdateBook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: true)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Libro guardado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanError] when DeleteScanBook fails',
      build: () {
        when(() => mockDeleteBook(any())).thenThrow(Exception('Error'));
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(DeleteScanBook(999)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanError>(),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when DeleteScanBook succeeds',
      build: () {
        when(() => mockDeleteBook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(DeleteScanBook(1)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Libro eliminado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when SaveScanBook creates new book',
      build: () {
        when(() => mockCreateBook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: false)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Libro creado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanError] when SaveScanBook fails',
      build: () {
        when(() => mockCreateBook(any())).thenThrow(Exception('Error al crear'));
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanBook(testBooks.first, isUpdate: false)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanError>().having((s) => s.message, 'message', contains('Error al crear')),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when SaveScanTook updates',
      build: () {
        when(() => mockUpdateTook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanTook(
        TookEntity(id: 1, createdAt: DateTime(2024), cover: '',
            number: '1', title: '', chapterCount: '', bookId: 1, listChapter: const []),
        isUpdate: true,
      )),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Tomo guardado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when SaveScanTook creates',
      build: () {
        when(() => mockCreateTook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanTook(
        TookEntity(id: 0, createdAt: DateTime(2024), cover: '',
            number: '1', title: '', chapterCount: '', bookId: 1, listChapter: const []),
        isUpdate: false,
      )),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Tomo creado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanError] when SaveScanTook fails',
      build: () {
        when(() => mockCreateTook(any())).thenThrow(Exception('Error'));
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanTook(
        TookEntity(id: 0, createdAt: DateTime(2024), cover: '',
            number: '1', title: '', chapterCount: '', bookId: 1, listChapter: const []),
        isUpdate: false,
      )),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanError>(),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when DeleteScanTook succeeds',
      build: () {
        when(() => mockDeleteTook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(DeleteScanTook(1)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Tomo eliminado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanError] when DeleteScanTook fails',
      build: () {
        when(() => mockDeleteTook(any())).thenThrow(Exception('Error'));
        return scanBloc;
      },
      act: (bloc) => bloc.add(DeleteScanTook(999)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanError>(),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when SaveScanChapter updates',
      build: () {
        when(() => mockUpdateChapter(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanChapter(
        ChapterEntity(id: 1, createdAt: DateTime(2024), number: '1',
            title: '', content: 'texto', tookId: 1),
        isUpdate: true,
      )),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Capítulo guardado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when SaveScanChapter creates',
      build: () {
        when(() => mockCreateChapter(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanChapter(
        ChapterEntity(id: 0, createdAt: DateTime(2024), number: '1',
            title: '', content: 'nuevo', tookId: 1),
        isUpdate: false,
      )),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Capítulo creado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanError] when SaveScanChapter fails',
      build: () {
        when(() => mockCreateChapter(any())).thenThrow(Exception('Error'));
        return scanBloc;
      },
      act: (bloc) => bloc.add(SaveScanChapter(
        ChapterEntity(id: 0, createdAt: DateTime(2024), number: '1',
            title: '', content: 'nuevo', tookId: 1),
        isUpdate: false,
      )),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanError>(),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanLoaded] when DeleteScanChapter succeeds',
      build: () {
        when(() => mockDeleteChapter(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return scanBloc;
      },
      act: (bloc) => bloc.add(DeleteScanChapter(1)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanLoaded>().having((s) => s.message, 'message', 'Capítulo eliminado'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'emits [ScanLoading, ScanError] when DeleteScanChapter fails',
      build: () {
        when(() => mockDeleteChapter(any())).thenThrow(Exception('Error'));
        return scanBloc;
      },
      act: (bloc) => bloc.add(DeleteScanChapter(999)),
      expect: () => [
        isA<ScanLoading>(),
        isA<ScanError>(),
      ],
    );
  });
}
