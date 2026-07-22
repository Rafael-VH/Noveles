import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';
import 'package:noveles/features/chapters/domain/mark_chapter_as_read.dart';

class MockChapterRepository extends Mock implements ChapterRepository {}

void main() {
  late MockChapterRepository mockRepository;
  late MarkChapterAsRead useCase;

  setUp(() {
    mockRepository = MockChapterRepository();
    useCase = MarkChapterAsRead(mockRepository);
  });

  group('MarkChapterAsRead', () {
    test('calls repository.markChapterAsRead and returns Ok on success', () async {
      when(() => mockRepository.markChapterAsRead(any(), any()))
          .thenAnswer((_) async => const Ok(null));

      final result = await useCase(1, 'user1');

      expect(result, isA<Ok<void>>());
      verify(() => mockRepository.markChapterAsRead(1, 'user1')).called(1);
    });

    test('returns Err when repository fails', () async {
      when(() => mockRepository.markChapterAsRead(any(), any()))
          .thenAnswer((_) async => Err(ChapterFailure('Insert failed')));

      final result = await useCase(1, 'user1');

      expect(result, isA<Err<void>>());
      final error = (result as Err<void>).error;
      expect(error.message, 'Insert failed');
    });
  });
}
