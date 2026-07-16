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

    test('props includes createdBy', () {
      expect(baseBook.props.any((p) => p == null), isTrue);
    });

    test('copyWith preserves fields', () {
      final copied = baseBook.copyWith(createdBy: 'new-user');
      expect(copied.createdBy, 'new-user');
      expect(copied.name, baseBook.name);
    });

    test('props includes listLabel', () {
      expect(baseBook.props.contains(baseBook.listLabelIds), true);
    });
  });
}
