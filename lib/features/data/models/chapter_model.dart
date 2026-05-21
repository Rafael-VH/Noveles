import 'package:noveles/features/domain/entities/entities.dart';

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
    id: json['id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    number: (json['number'] as String?) ?? '',
    title: (json['title'] as String?) ?? '',
    content: (json['content'] as String?) ?? '',
    tookId: (json['took_id'] as int?) ?? 0,
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
