import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

void main() {
  group('TookEntity', () {
    final baseTook = TookEntity(
      id: 1,
      createdAt: DateTime(2026),
      cover: 'cover.jpg',
      number: '1',
      title: 'Tomo 1',
      chapterCount: '10',
      bookId: 1,
      listChapter: const [],
      createdBy: null,
    );

    test('creates with required values', () {
      expect(baseTook.id, 1);
      expect(baseTook.title, 'Tomo 1');
    });

    test('createdBy is nullable', () {
      expect(baseTook.createdBy, isNull);
      final withCreator = TookEntity(
        id: 2,
        createdAt: DateTime(2026),
        cover: '',
        number: '2',
        title: 'Tomo 2',
        chapterCount: '5',
        bookId: 1,
        listChapter: const [],
        createdBy: 'user-uuid',
      );
      expect(withCreator.createdBy, 'user-uuid');
    });

    test('props includes createdBy', () {
      expect(baseTook.props.any((p) => p == null), isTrue);
    });
  });
}
