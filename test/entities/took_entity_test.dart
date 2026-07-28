import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

void main() {
  group('TookEntity', () {
    final baseTook = TookEntity(
      id: 1,
      createdAt: DateTime(2026),
      cover: 'cover.jpg',
      number: '1',
      title: 'Tomo 1',
      chapterCount: 10,
      bookId: 1,
      listChapterIds: const [],
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
        chapterCount: 5,
        bookId: 1,
        listChapterIds: const [],
        createdBy: 'user-uuid',
      );
      expect(withCreator.createdBy, 'user-uuid');
    });

    test('equatable — same values are equal', () {
      final same = TookEntity(
        id: 1,
        createdAt: DateTime(2026),
        cover: 'cover.jpg',
        number: '1',
        title: 'Tomo 1',
        chapterCount: 10,
        bookId: 1,
        listChapterIds: const [],
        createdBy: null,
      );
      expect(baseTook == same, isTrue);
      expect(baseTook.hashCode, same.hashCode);
    });

    test('equatable — different id is not equal', () {
      final other = TookEntity(
        id: 999,
        createdAt: DateTime(2026),
        cover: 'cover.jpg',
        number: '1',
        title: 'Tomo 1',
        chapterCount: 10,
        bookId: 1,
      );
      expect(baseTook == other, isFalse);
    });

    test('equatable — different title is not equal', () {
      final other = TookEntity(
        id: 1,
        createdAt: DateTime(2026),
        cover: 'cover.jpg',
        number: '1',
        title: 'Different',
        chapterCount: 10,
        bookId: 1,
      );
      expect(baseTook == other, isFalse);
    });

    test('props contains all fields', () {
      expect(baseTook.props, [
        baseTook.id,
        baseTook.createdAt,
        baseTook.cover,
        baseTook.number,
        baseTook.title,
        baseTook.chapterCount,
        baseTook.bookId,
        baseTook.listChapterIds,
        baseTook.chapters,
        baseTook.createdBy,
      ]);
    });

    test('chapters defaults to empty list', () {
      expect(baseTook.chapters, []);
    });

    test('can set chapters', () {
      final chapter = ChapterEntity(
        id: 1,
        createdAt: DateTime(2026),
        number: '1',
        title: 'Ch 1',
        content: 'text',
        tookId: 1,
      );
      final took = TookEntity(
        id: 2,
        createdAt: DateTime(2026),
        cover: '',
        number: '1',
        title: 'With Chapters',
        chapterCount: 1,
        bookId: 1,
        chapters: [chapter],
      );
      expect(took.chapters.length, 1);
      expect(took.chapters.first.id, 1);
    });

    test('listChapterIds defaults to empty list', () {
      expect(baseTook.listChapterIds, []);
    });
  });
}
