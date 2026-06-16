import 'package:noveles/features/genres/domain/genre_entity.dart';

class GenreModel extends GenreEntity {
  const GenreModel({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.description,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) => GenreModel(
        id: json['id'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        name: (json['name'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  factory GenreModel.fromEntity(GenreEntity entity) => GenreModel(
        id: entity.id,
        createdAt: entity.createdAt,
        name: entity.name,
        description: entity.description,
      );
}
