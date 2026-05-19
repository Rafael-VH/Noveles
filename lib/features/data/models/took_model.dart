import 'package:noveles/features/data/models/chapter_model.dart';
import 'package:noveles/features/domain/entities/entities.dart';

class TookModel extends TookEntity {
  const TookModel({
    required super.id,
    required super.createdAt,
    required super.cover,
    required super.number,
    required super.title,
    required super.chapterCount,
    required super.bookId,
    required super.listChapter,
  });

  factory TookModel.fromJson(Map<String, dynamic> json) {
    final chapters = ((json['chapters'] as List<dynamic>?) ?? []).map((ch) {
      return ChapterModel.fromJson(Map<String, dynamic>.from(ch));
    }).toList();

    return TookModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at'] as String),
      cover: (json['cover'] as String?) ?? '',
      number: (json['number'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      chapterCount: (json['chapter_count'] as String?) ?? (json['content'] as String?) ?? '',
      bookId: (json['book_id'] as int?) ?? 0,
      listChapter: chapters,
    );
  }

  Map<String, dynamic> toJson() => {
    'cover': cover,
    'number': number,
    'title': title,
    'chapter_count': chapterCount,
    'book_id': bookId,
  };

  factory TookModel.fromEntity(TookEntity entity) => TookModel(
    id: entity.id,
    createdAt: entity.createdAt,
    cover: entity.cover,
    number: entity.number,
    title: entity.title,
    chapterCount: entity.chapterCount,
    bookId: entity.bookId,
    listChapter: entity.listChapter,
  );
}
