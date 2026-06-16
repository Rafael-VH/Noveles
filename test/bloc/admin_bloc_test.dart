import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/delete_book.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/toggle_book_visibility.dart'
    as usecases;
import 'package:noveles/features/presentation/bloc/admin/admin_bloc.dart';
import 'package:noveles/features/presentation/bloc/admin/admin_event.dart';
import 'package:noveles/features/presentation/bloc/admin/admin_state.dart';

class MockGetBooks extends Mock implements GetBooks {}

class MockToggleBookVisibility extends Mock
    implements usecases.ToggleBookVisibility {}

class MockDeleteBook extends Mock implements DeleteBook {}

void main() {
  late MockGetBooks mockGetBooks;
  late MockToggleBookVisibility mockToggleVisibility;
  late MockDeleteBook mockDeleteBook;

  final testBooks = [
    BookEntity(
      id: 1,
      createdAt: DateTime(2024),
      cover: 'cover.jpg',
      name: 'Admin Book',
      short: '',
      alternative: '',
      description: '',
      authorId: 1,
      author: 'Author',
      country: 'JP',
      state: 'ongoing',
      type: 'novel',
      release: '2024',
      tookCount: 5,
      chapterCount: 10,
      source: '',
      link: '',
      isFavorite: false,
      isVisible: true,
      listGenre: const [],
      listTook: const [],
      listLabel: const [],
    ),
  ];

  setUp(() {
    mockGetBooks = MockGetBooks();
    mockToggleVisibility = MockToggleBookVisibility();
    mockDeleteBook = MockDeleteBook();
  });

  group('AdminBloc', () {
    test('initial state is AdminInitial', () {
      final bloc = AdminBloc(
        getBooks: mockGetBooks,
        toggleBookVisibility: mockToggleVisibility,
        deleteBook: mockDeleteBook,
      );
      expect(bloc.state, const AdminInitial());
      bloc.close();
    });

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminLoaded] when LoadAdminBooks succeeds',
      build: () {
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return AdminBloc(
          getBooks: mockGetBooks,
          toggleBookVisibility: mockToggleVisibility,
          deleteBook: mockDeleteBook,
        );
      },
      act: (bloc) => bloc.add(const LoadAdminBooks()),
      expect: () => [
        const AdminLoading(),
        isA<AdminLoaded>().having(
          (s) => s.books.length,
          'book count',
          1,
        ),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when LoadAdminBooks fails',
      build: () {
        when(() => mockGetBooks())
            .thenAnswer((_) async => Err(BookFailure('Error de red')));
        return AdminBloc(
          getBooks: mockGetBooks,
          toggleBookVisibility: mockToggleVisibility,
          deleteBook: mockDeleteBook,
        );
      },
      act: (bloc) => bloc.add(const LoadAdminBooks()),
      expect: () => [
        const AdminLoading(),
        isA<AdminError>().having(
          (s) => s.message,
          'message',
          contains('Error de red'),
        ),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits AdminLoaded with message when ToggleBookVisibility succeeds',
      build: () {
        when(() => mockToggleVisibility(any(), any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return AdminBloc(
          getBooks: mockGetBooks,
          toggleBookVisibility: mockToggleVisibility,
          deleteBook: mockDeleteBook,
        );
      },
      act: (bloc) => bloc.add(const ToggleBookVisibility(1, true)),
      expect: () => [
        isA<AdminLoaded>().having(
          (s) => s.message,
          'message',
          'Libro publicado',
        ),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits AdminLoaded with hidden message when ToggleBookVisibility hides',
      build: () {
        when(() => mockToggleVisibility(any(), any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return AdminBloc(
          getBooks: mockGetBooks,
          toggleBookVisibility: mockToggleVisibility,
          deleteBook: mockDeleteBook,
        );
      },
      act: (bloc) => bloc.add(const ToggleBookVisibility(1, false)),
      expect: () => [
        isA<AdminLoaded>().having(
          (s) => s.message,
          'message',
          'Libro ocultado',
        ),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits AdminError when ToggleBookVisibility fails',
      build: () {
        when(() => mockToggleVisibility(any(), any()))
            .thenAnswer((_) async => Err(BookFailure('Error de visibilidad')));
        return AdminBloc(
          getBooks: mockGetBooks,
          toggleBookVisibility: mockToggleVisibility,
          deleteBook: mockDeleteBook,
        );
      },
      act: (bloc) => bloc.add(const ToggleBookVisibility(1, true)),
      expect: () => [
        isA<AdminError>().having(
          (s) => s.message,
          'message',
          contains('Error de visibilidad'),
        ),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits AdminLoaded with message when DeleteAdminBook succeeds',
      build: () {
        when(() => mockDeleteBook(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetBooks()).thenAnswer((_) async => Ok(testBooks));
        return AdminBloc(
          getBooks: mockGetBooks,
          toggleBookVisibility: mockToggleVisibility,
          deleteBook: mockDeleteBook,
        );
      },
      act: (bloc) => bloc.add(const DeleteAdminBook(1)),
      expect: () => [
        isA<AdminLoaded>().having(
          (s) => s.message,
          'message',
          'Libro eliminado',
        ),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits AdminError when DeleteAdminBook fails',
      build: () {
        when(() => mockDeleteBook(any()))
            .thenAnswer((_) async => Err(BookFailure('Delete error')));
        return AdminBloc(
          getBooks: mockGetBooks,
          toggleBookVisibility: mockToggleVisibility,
          deleteBook: mockDeleteBook,
        );
      },
      act: (bloc) => bloc.add(const DeleteAdminBook(1)),
      expect: () => [
        isA<AdminError>().having(
          (s) => s.message,
          'message',
          contains('Delete error'),
        ),
      ],
    );
  });
}
