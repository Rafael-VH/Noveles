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

void main() {
  late MockGetBooks mockGetBooks;
  late MockCreateBook mockCreateBook;
  late MockUpdateBook mockUpdateBook;
  late MockDeleteBook mockDeleteBook;
  late AdminBloc adminBloc;

  final testBooks = [
    BookEntity(
      id: 1, createdAt: DateTime(2024), cover: 'cover.png',
      name: 'Test Book', short: '', alternative: '', description: '',
      authorId: 1, author: 'Author', country: 'JP', state: 'ongoing',
      type: 'novel', release: '2024', tookCount: '1', chapterCount: '10',
      source: '', link: '', isFavorite: false, listGenre: [], listTook: [],
    ),
  ];

  setUpAll(() {
    registerFallbackValue(BookEntity(
      id: 0, createdAt: DateTime(2024), cover: '',
      name: '', short: '', alternative: '', description: '',
      authorId: 0, author: '', country: '', state: '',
      type: '', release: '', tookCount: '', chapterCount: '',
      source: '', link: '', isFavorite: false, listGenre: [], listTook: [],
    ));
  });

  setUp(() {
    mockGetBooks = MockGetBooks();
    mockCreateBook = MockCreateBook();
    mockUpdateBook = MockUpdateBook();
    mockDeleteBook = MockDeleteBook();
    adminBloc = AdminBloc(
      getBooks: mockGetBooks,
      createBook: mockCreateBook,
      updateBook: mockUpdateBook,
      deleteBook: mockDeleteBook,
      createTook: MockCreateTook(),
      updateTook: MockUpdateTook(),
      deleteTook: MockDeleteTook(),
      createChapter: MockCreateChapter(),
      updateChapter: MockUpdateChapter(),
      deleteChapter: MockDeleteChapter(),
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
  });
}
