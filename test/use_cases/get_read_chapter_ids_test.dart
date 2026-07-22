import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';
import 'package:noveles/features/chapters/domain/get_read_chapter_ids.dart';

class MockChapterRepository extends Mock implements ChapterRepository {}

void main() {
  late MockChapterRepository mockRepository;
  late GetReadChapterIds useCase;

  setUp(() {
    mockRepository = MockChapterRepository();
    useCase = GetReadChapterIds(mockRepository);
  });

  group('GetReadChapterIds', () {
    test('calls repository.getReadChapterIds and returns Ok on success', () async {
      when(() => mockRepository.getReadChapterIds(any(), any()))
          .thenAnswer((_) async => const Ok({1, 2, 3}));

      final result = await useCase(5, 'user1');

      expect(result, isA<Ok<Set<int>>>());
      final value = (result as Ok<Set<int>>).value;
      expect(value, {1, 2, 3});
      verify(() => mockRepository.getReadChapterIds(5, 'user1')).called(1);
    });

    test('returns Err when repository fails', () async {
      when(() => mockRepository.getReadChapterIds(any(), any()))
          .thenAnswer((_) async => Err(ChapterFailure('Query failed')));

      final result = await useCase(5, 'user1');

      expect(result, isA<Err<Set<int>>>());
      final error = (result as Err<Set<int>>).error;
      expect(error.message, 'Query failed');
    });
  });
}
