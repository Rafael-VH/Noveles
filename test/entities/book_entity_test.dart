import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';

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
      tookCount: '1',
      chapterCount: '10',
      source: 'web',
      link: '',
      isFavorite: false,
      isVisible: true,
      listGenre: const [],
      listTook: const [],
      listLabel: const [],
      createdBy: null,
    );

    test('creates with required values', () {
      expect(baseBook.id, 1);
      expect(baseBook.name, 'Test Book');
      expect(baseBook.listLabel, []);
    });

    test('listLabel accepts labels', () {
      final label = LabelEntity(
        id: 1,
        createdAt: DateTime(2026),
        name: 'Staff Pick',
        color: '#71A202',
      );
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
        tookCount: '1',
        chapterCount: '10',
        source: 'web',
        link: '',
        isFavorite: false,
        isVisible: true,
        listGenre: const [],
        listTook: const [],
        listLabel: [label],
        createdBy: null,
      );
      expect(book.listLabel.length, 1);
      expect(book.listLabel.first.name, 'Staff Pick');
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
        tookCount: '1',
        chapterCount: '10',
        source: 'web',
        link: '',
        isFavorite: false,
        isVisible: true,
        listGenre: const [],
        listTook: const [],
        listLabel: const [],
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
      expect(baseBook.props.contains(baseBook.listLabel), true);
    });
  });
}
