import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

void main() {
  group('ChapterEntity', () {
    final baseChapter = ChapterEntity(
      id: 1,
      createdAt: DateTime(2026),
      number: '1',
      title: 'Chapter 1',
      content: 'content.txt',
      tookId: 1,
      createdBy: null,
    );

    test('creates with required values', () {
      expect(baseChapter.id, 1);
      expect(baseChapter.title, 'Chapter 1');
    });

    test('createdBy is nullable', () {
      expect(baseChapter.createdBy, isNull);
      final withCreator = ChapterEntity(
        id: 2,
        createdAt: DateTime(2026),
        number: '2',
        title: 'Chapter 2',
        content: 'content2.txt',
        tookId: 1,
        createdBy: 'user-uuid',
      );
      expect(withCreator.createdBy, 'user-uuid');
    });

    test('props includes createdBy', () {
      expect(baseChapter.props.any((p) => p == null), isTrue);
    });
  });
}
