import 'package:equatable/equatable.dart';

class GenreEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;

  const GenreEntity({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  GenreEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
  }) {
    return GenreEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  List<Object> get props => [
        id,
        createdAt,
        name,
        description,
      ];
}
