import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/books/domain/book_entity.dart';

void main() {
  group('BookEntity', () {
    final baseBook = BookEntity(
      id: 1,
      createdAt: DateTime(2026),
      cover: 'cover.jpg',
      name: 'Test Book',
      short: 'Test',
      alternative: '',
      description: 'A test book',
      authorId: 1,
      author: 'Author',
      country: 'US',
      state: 'active',
      type: 'novel',
      release: '2026',
      tookCount: 1,
      chapterCount: 10,
      source: 'web',
      link: '',
      isFavorite: false,
      isVisible: true,
      listGenreIds: const [],
      listTookIds: const [],
      listLabelIds: const [],
      createdBy: null,
    );

    test('creates with required values', () {
      expect(baseBook.id, 1);
      expect(baseBook.name, 'Test Book');
      expect(baseBook.listLabelIds, []);
    });

    test('listLabelIds accepts label ids', () {
      final book = BookEntity(
        id: 1,
        createdAt: DateTime(2026),
        cover: 'cover.jpg',
        name: 'Test Book',
        short: 'Test',
        alternative: '',
        description: 'A test book',
        authorId: 1,
        author: 'Author',
        country: 'US',
        state: 'active',
        type: 'novel',
        release: '2026',
        tookCount: 1,
        chapterCount: 10,
        source: 'web',
        link: '',
        isFavorite: false,
        isVisible: true,
        listGenreIds: const [],
        listTookIds: const [],
        listLabelIds: [1],
        createdBy: null,
      );
      expect(book.listLabelIds.length, 1);
      expect(book.listLabelIds.first, 1);
    });

    test('createdBy is nullable and settable', () {
      expect(baseBook.createdBy, isNull);
      final withCreator = BookEntity(
        id: 1,
        createdAt: DateTime(2026),
        cover: 'cover.jpg',
        name: 'Test Book',
        short: 'Test',
        alternative: '',
        description: 'A test book',
        authorId: 1,
        author: 'Author',
        country: 'US',
        state: 'active',
        type: 'novel',
        release: '2026',
        tookCount: 1,
        chapterCount: 10,
        source: 'web',
        link: '',
        isFavorite: false,
        isVisible: true,
        listGenreIds: const [],
        listTookIds: const [],
        listLabelIds: const [],
        createdBy: 'user-uuid',
      );
      expect(withCreator.createdBy, 'user-uuid');
    });

    test('equatable — same values are equal', () {
      final same = BookEntity(
        id: 1,
        createdAt: DateTime(2026),
        cover: 'cover.jpg',
        name: 'Test Book',
        short: 'Test',
        alternative: '',
        description: 'A test book',
        authorId: 1,
        author: 'Author',
        country: 'US',
        state: 'active',
        type: 'novel',
        release: '2026',
        tookCount: 1,
        chapterCount: 10,
        source: 'web',
        link: '',
        isFavorite: false,
        isVisible: true,
        listGenreIds: const [],
        listTookIds: const [],
        listLabelIds: const [],
        createdBy: null,
      );
      expect(baseBook == same, isTrue);
      expect(baseBook.hashCode, same.hashCode);
    });

    test('equatable — different id is not equal', () {
      final other = baseBook.copyWith(id: 999);
      expect(baseBook == other, isFalse);
    });

    test('equatable — different name is not equal', () {
      final other = baseBook.copyWith(name: 'Different');
      expect(baseBook == other, isFalse);
    });

    test('props contains all fields', () {
      expect(baseBook.props, [
        baseBook.id,
        baseBook.createdAt,
        baseBook.cover,
        baseBook.name,
        baseBook.short,
        baseBook.alternative,
        baseBook.description,
        baseBook.authorId,
        baseBook.author,
        baseBook.country,
        baseBook.state,
        baseBook.type,
        baseBook.release,
        baseBook.tookCount,
        baseBook.chapterCount,
        baseBook.source,
        baseBook.link,
        baseBook.isFavorite,
        baseBook.isVisible,
        baseBook.listGenreIds,
        baseBook.listTookIds,
        baseBook.listLabelIds,
        baseBook.createdBy,
      ]);
    });

    test('copyWith preserves fields', () {
      final copied = baseBook.copyWith(createdBy: 'new-user');
      expect(copied.createdBy, 'new-user');
      expect(copied.name, baseBook.name);
    });

    test('copyWith changes only specified field', () {
      final copied = baseBook.copyWith(name: 'Renamed');
      expect(copied.name, 'Renamed');
      expect(copied.id, baseBook.id);
      expect(copied.author, baseBook.author);
    });

  });
}
