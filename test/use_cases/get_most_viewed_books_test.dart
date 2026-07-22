import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/features/books/domain/get_most_viewed_books.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockRepository;
  late GetMostViewedBooks useCase;

  setUp(() {
    mockRepository = MockBookRepository();
    useCase = GetMostViewedBooks(mockRepository);
  });

  group('GetMostViewedBooks', () {
    test('calls repository.getMostViewedBooks and returns Ok on success', () async {
      when(() => mockRepository.getMostViewedBooks())
          .thenAnswer((_) async => const Ok(<BookWithRelations>[]));

      final result = await useCase();

      expect(result, isA<Ok<List<BookWithRelations>>>());
      verify(() => mockRepository.getMostViewedBooks()).called(1);
    });

    test('returns Err when repository fails', () async {
      when(() => mockRepository.getMostViewedBooks())
          .thenAnswer((_) async => Err(BookFailure('RPC failed')));

      final result = await useCase();

      expect(result, isA<Err<List<BookWithRelations>>>());
      final error = (result as Err<List<BookWithRelations>>).error;
      expect(error.message, 'RPC failed');
    });
  });
}
