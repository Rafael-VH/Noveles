import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/chapters/data/chapter_model.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_ref.dart';

void main() {
  group('ChapterContentType', () {
    test('has inline value', () {
      expect(ChapterContentType.inline, isA<ChapterContentType>());
    });

    test('has storagePath value', () {
      expect(ChapterContentType.storagePath, isA<ChapterContentType>());
    });

    test('defaults to storagePath for existing content', () {
      expect(ChapterContentType.values, contains(ChapterContentType.storagePath));
    });

    test('name serialization matches DB convention', () {
      expect(ChapterContentType.inline.name, 'inline');
      expect(ChapterContentType.storagePath.name, 'storagePath');
    });
  });

  group('ChapterEntity contentType', () {
    final baseChapter = ChapterEntity(
      id: 1,
      createdAt: DateTime(2026),
      number: '1',
      title: 'Chapter 1',
      content: 'content.txt',
      tookId: 1,
      createdBy: null,
    );

    test('default contentType is storagePath', () {
      expect(baseChapter.contentType, ChapterContentType.storagePath);
    });

    test('can create with inline contentType', () {
      final chapter = ChapterEntity(
        id: 2,
        createdAt: DateTime(2026),
        number: '2',
        title: 'Inline Chapter',
        content: 'This is inline content',
        tookId: 1,
        contentType: ChapterContentType.inline,
      );
      expect(chapter.contentType, ChapterContentType.inline);
    });

    test('props includes contentType', () {
      final chapter = ChapterEntity(
        id: 5,
        createdAt: DateTime(2026),
        number: '5',
        title: 'Chapter 5',
        content: 'content',
        tookId: 1,
        contentType: ChapterContentType.inline,
      );
      expect(chapter.props, contains(ChapterContentType.inline));
    });
  });

  group('ChapterRef contentType', () {
    test('fromEntity carries contentType from entity', () {
      final entity = ChapterEntity(
        id: 1,
        createdAt: DateTime(2026),
        number: '1',
        title: 'Chapter 1',
        content: 'ch1.txt',
        tookId: 1,
        contentType: ChapterContentType.storagePath,
      );
      final ref = ChapterRef.fromEntity(entity);
      expect(ref.contentType, ChapterContentType.storagePath);
    });

    test('can create ref with inline contentType', () {
      final ref = const ChapterRef(
        id: 2,
        content: 'inline text',
        number: '2',
        title: 'Chapter 2',
        tookId: 1,
        contentType: ChapterContentType.inline,
      );
      expect(ref.contentType, ChapterContentType.inline);
    });

    test('props includes contentType', () {
      final ref = const ChapterRef(
        id: 1,
        content: 'content',
        number: '1',
        title: 'Chapter 1',
        tookId: 1,
        contentType: ChapterContentType.storagePath,
      );
      expect(ref.props, contains(ChapterContentType.storagePath));
    });
  });

  group('ChapterModel contentType serialization', () {
    test('fromJson reads content_type field', () {
      final json = {
        'id': 1,
        'created_at': '2026-01-01T00:00:00.000',
        'number': '1',
        'title': 'Chapter 1',
        'content': 'ch1.txt',
        'took_id': 1,
        'content_type': 'inline',
      };
      final model = ChapterModel.fromJson(json);
      expect(model.contentType, ChapterContentType.inline);
    });

    test('fromJson defaults to storagePath for null content_type', () {
      final json = {
        'id': 1,
        'created_at': '2026-01-01T00:00:00.000',
        'number': '1',
        'title': 'Chapter 1',
        'content': 'ch1.txt',
        'took_id': 1,
      };
      final model = ChapterModel.fromJson(json);
      expect(model.contentType, ChapterContentType.storagePath);
    });

    test('toJson writes content_type field', () {
      final model = ChapterModel(
        id: 1,
        createdAt: DateTime(2026),
        number: '1',
        title: 'Chapter 1',
        content: 'ch1.txt',
        tookId: 1,
        contentType: ChapterContentType.storagePath,
      );
      final json = model.toJson();
      expect(json['content_type'], 'storagePath');
    });

    test('toJson writes inline content_type', () {
      final model = ChapterModel(
        id: 2,
        createdAt: DateTime(2026),
        number: '2',
        title: 'Chapter 2',
        content: 'inline text',
        tookId: 1,
        contentType: ChapterContentType.inline,
      );
      final json = model.toJson();
      expect(json['content_type'], 'inline');
    });

    test('fromJson toJson roundtrip preserves contentType', () {
      final original = {
        'id': 3,
        'created_at': '2026-06-01T00:00:00.000',
        'number': '3',
        'title': 'Roundtrip',
        'content': 'ch3.txt',
        'took_id': 1,
        'content_type': 'storagePath',
      };
      final model = ChapterModel.fromJson(original);
      final serialized = model.toJson();
      expect(serialized['content_type'], 'storagePath');
    });

    test('fromEntity preserves contentType', () {
      final entity = ChapterEntity(
        id: 1,
        createdAt: DateTime(2026),
        number: '1',
        title: 'Chapter 1',
        content: 'ch1.txt',
        tookId: 1,
        contentType: ChapterContentType.inline,
      );
      final model = ChapterModel.fromEntity(entity);
      expect(model.contentType, ChapterContentType.inline);
    });
  });
}
