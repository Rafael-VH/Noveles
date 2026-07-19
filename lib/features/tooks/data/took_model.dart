import 'package:noveles/core/utils/parse_utils.dart';
import 'package:noveles/features/chapters/data/chapter_model.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

/// Data-layer model that hydrates full [ChapterEntity] objects from Supabase.
/// Domain layer only knows about [listChapterIds] (int IDs);
/// presentation layers that need full chapters cast to [TookModel].
class TookModel extends TookEntity {
  final List<ChapterEntity> chapters;

  const TookModel({
    required super.id,
    required super.createdAt,
    required super.cover,
    required super.number,
    required super.title,
    required super.chapterCount,
    required super.bookId,
    super.listChapterIds = const [],
    super.createdBy,
    this.chapters = const [],
  });

  factory TookModel.fromJson(Map<String, dynamic> json) {
    final chapters = ((json['chapters'] as List<dynamic>?) ?? []).map((ch) {
      return ChapterModel.fromJson(Map<String, dynamic>.from(ch));
    }).toList();

    return TookModel(
      id: parseInt(json['id']),
      createdAt: DateTime.parse(json['created_at'] as String),
      cover: (json['cover'] as String?) ?? '',
      number: (json['number'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      chapterCount: parseInt(json['chapter_count'], 0),
      bookId: parseInt(json['book_id'], 0),
      createdBy: json['created_by'] as String?,
      listChapterIds: chapters.map((c) => c.id).toList(),
      chapters: chapters,
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
        listChapterIds: entity.listChapterIds,
        createdBy: entity.createdBy,
      );
}
