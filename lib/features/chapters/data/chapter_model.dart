import 'package:noveles/core/utils/parse_utils.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

class ChapterModel extends ChapterEntity {
  const ChapterModel({
    required super.id,
    required super.createdAt,
    required super.number,
    required super.title,
    required super.content,
    required super.tookId,
    super.createdBy,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
        id: parseInt(json['id']),
        createdAt: DateTime.parse(json['created_at'] as String),
        number: (json['number'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
        tookId: parseInt(json['took_id'], 0),
        createdBy: json['created_by'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'content': content,
        'took_id': tookId,
        'created_by': createdBy,
      };

  factory ChapterModel.fromEntity(ChapterEntity entity) => ChapterModel(
        id: entity.id,
        createdAt: entity.createdAt,
        number: entity.number,
        title: entity.title,
        content: entity.content,
        tookId: entity.tookId,
        createdBy: entity.createdBy,
      );
}
