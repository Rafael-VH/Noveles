import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/domain/entities/entities.dart';

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
      listGenre: [],
      listTook: [],
      listLabel: [],
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
        listGenre: [],
        listTook: [],
        listLabel: [label],
      );
      expect(book.listLabel.length, 1);
      expect(book.listLabel.first.name, 'Staff Pick');
    });

    test('props includes listLabel', () {
      expect(baseBook.props.contains(baseBook.listLabel), true);
    });
  });
}
