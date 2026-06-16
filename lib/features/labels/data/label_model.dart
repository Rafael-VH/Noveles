import 'package:noveles/features/labels/domain/label_entity.dart';

class LabelModel extends LabelEntity {
  const LabelModel({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.color,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) => LabelModel(
        id: json['id'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        name: (json['name'] as String?) ?? '',
        color: (json['color'] as String?) ?? '#71A202',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
      };

  factory LabelModel.fromEntity(LabelEntity entity) => LabelModel(
        id: entity.id,
        createdAt: entity.createdAt,
        name: entity.name,
        color: entity.color,
      );
}
