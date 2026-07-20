import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/features/books/domain/track_book_view.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockRepository;
  late TrackBookView useCase;

  setUp(() {
    mockRepository = MockBookRepository();
    useCase = TrackBookView(mockRepository);
  });

  group('TrackBookView', () {
    test('calls repository.trackBookView and returns Ok on success', () async {
      when(() => mockRepository.trackBookView(any()))
          .thenAnswer((_) async => const Ok(null));

      final result = await useCase(42);

      expect(result, isA<Ok<void>>());
      verify(() => mockRepository.trackBookView(42)).called(1);
    });

    test('returns Err when repository fails', () async {
      when(() => mockRepository.trackBookView(any()))
          .thenAnswer((_) async => Err(BookFailure('Insert failed')));

      final result = await useCase(1);

      expect(result, isA<Err<void>>());
      final error = (result as Err<void>).error;
      expect(error.message, 'Insert failed');
    });
  });
}
