import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/admin_bloc.dart';
import 'package:noveles/features/presentation/bloc/admin_event.dart';
import 'package:noveles/features/presentation/bloc/admin_state.dart';

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
  late AdminBloc adminBloc;

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
    adminBloc = AdminBloc(
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
    );
  });

  tearDown(() {
    adminBloc.close();
  });

  group('AdminBloc', () {
    test('initial state is AdminInitial', () {
      expect(adminBloc.state, equals(AdminInitial()));
    });

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when LoadAdminBooks succeeds',
      build: () {
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(LoadAdminBooks()),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.books, 'books', testBooks),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when LoadAdminBooks fails',
      build: () {
        when(() => mockGetBooks()).thenThrow(Exception('Error de red'));
        return adminBloc;
      },
      act: (bloc) => bloc.add(LoadAdminBooks()),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminError>().having((s) => s.message, 'message', contains('Error de red')),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits AdminGenresLoaded when LoadAdminGenres succeeds',
      build: () {
        final genres = [
          GenreEntity(id: 1, createdAt: DateTime(2024), name: 'Acción', description: ''),
          GenreEntity(id: 2, createdAt: DateTime(2024), name: 'Romance', description: ''),
        ];
        when(() => mockGetGenre()).thenAnswer((_) async => genres);
        return adminBloc;
      },
      act: (bloc) => bloc.add(LoadAdminGenres()),
      expect: () => [
        isA<AdminGenresLoaded>()
            .having((s) => s.genres.length, 'genre count', 2)
            .having((s) => s.genres.first.name, 'first genre name', 'Acción'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when SaveAdminBook succeeds',
      build: () {
        when(() => mockUpdateBook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminBook(testBooks.first, isUpdate: true)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Libro guardado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when DeleteAdminBook fails',
      build: () {
        when(() => mockDeleteBook(any())).thenThrow(Exception('Error'));
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(DeleteAdminBook(999)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminError>(),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when DeleteAdminBook succeeds',
      build: () {
        when(() => mockDeleteBook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(DeleteAdminBook(1)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Libro eliminado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when SaveAdminBook creates new book',
      build: () {
        when(() => mockCreateBook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminBook(testBooks.first, isUpdate: false)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Libro creado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when SaveAdminBook fails',
      build: () {
        when(() => mockCreateBook(any())).thenThrow(Exception('Error al crear'));
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminBook(testBooks.first, isUpdate: false)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminError>().having((s) => s.message, 'message', contains('Error al crear')),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when SaveAdminTook updates',
      build: () {
        when(() => mockUpdateTook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminTook(
        TookEntity(id: 1, createdAt: DateTime(2024), cover: '',
            number: '1', title: '', chapterCount: '', bookId: 1, listChapter: const []),
        isUpdate: true,
      )),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Tomo guardado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when SaveAdminTook creates',
      build: () {
        when(() => mockCreateTook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminTook(
        TookEntity(id: 0, createdAt: DateTime(2024), cover: '',
            number: '1', title: '', chapterCount: '', bookId: 1, listChapter: const []),
        isUpdate: false,
      )),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Tomo creado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when SaveAdminTook fails',
      build: () {
        when(() => mockCreateTook(any())).thenThrow(Exception('Error'));
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminTook(
        TookEntity(id: 0, createdAt: DateTime(2024), cover: '',
            number: '1', title: '', chapterCount: '', bookId: 1, listChapter: const []),
        isUpdate: false,
      )),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminError>(),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when DeleteAdminTook succeeds',
      build: () {
        when(() => mockDeleteTook(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(DeleteAdminTook(1)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Tomo eliminado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when DeleteAdminTook fails',
      build: () {
        when(() => mockDeleteTook(any())).thenThrow(Exception('Error'));
        return adminBloc;
      },
      act: (bloc) => bloc.add(DeleteAdminTook(999)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminError>(),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when SaveAdminChapter updates',
      build: () {
        when(() => mockUpdateChapter(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminChapter(
        ChapterEntity(id: 1, createdAt: DateTime(2024), number: '1',
            title: '', content: 'texto', tookId: 1),
        isUpdate: true,
      )),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Capítulo guardado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when SaveAdminChapter creates',
      build: () {
        when(() => mockCreateChapter(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminChapter(
        ChapterEntity(id: 0, createdAt: DateTime(2024), number: '1',
            title: '', content: 'nuevo', tookId: 1),
        isUpdate: false,
      )),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Capítulo creado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when SaveAdminChapter fails',
      build: () {
        when(() => mockCreateChapter(any())).thenThrow(Exception('Error'));
        return adminBloc;
      },
      act: (bloc) => bloc.add(SaveAdminChapter(
        ChapterEntity(id: 0, createdAt: DateTime(2024), number: '1',
            title: '', content: 'nuevo', tookId: 1),
        isUpdate: false,
      )),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminError>(),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when DeleteAdminChapter succeeds',
      build: () {
        when(() => mockDeleteChapter(any())).thenAnswer((_) async {});
        when(() => mockGetBooks()).thenAnswer((_) async => testBooks);
        return adminBloc;
      },
      act: (bloc) => bloc.add(DeleteAdminChapter(1)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminLoaded>().having((s) => s.message, 'message', 'Capítulo eliminado'),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when DeleteAdminChapter fails',
      build: () {
        when(() => mockDeleteChapter(any())).thenThrow(Exception('Error'));
        return adminBloc;
      },
      act: (bloc) => bloc.add(DeleteAdminChapter(999)),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminError>(),
      ],
    );
  });
}
