import 'package:noveles/features/chapters/data/chapter_model.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

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
    super.createdBy,
  });

  factory TookModel.fromJson(Map<String, dynamic> json) {
    final chapters = ((json['chapters'] as List<dynamic>?) ?? []).map((ch) {
      return ChapterModel.fromJson(Map<String, dynamic>.from(ch));
    }).toList();

    return TookModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      cover: (json['cover'] as String?) ?? '',
      number: (json['number'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      chapterCount: (json['chapter_count'] as int?) ?? 0,
      bookId: (json['book_id'] as int?) ?? 0,
      createdBy: json['created_by'] as String?,
      listChapter: chapters,
    );
  }

  Map<String, dynamic> toJson() => {
        'cover': cover,
        'number': number,
        'title': title,
        'chapter_count': chapterCount,
        'book_id': bookId,
        'created_by': createdBy,
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
        createdBy: entity.createdBy,
      );
}
