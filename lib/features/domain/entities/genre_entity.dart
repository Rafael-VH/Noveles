class GenreEntity {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;

  GenreEntity({
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'description': description,
    };
  }

  factory GenreEntity.fromMap(Map<String, dynamic> map) {
    return GenreEntity(
      id: map['id'],
      createdAt: DateTime.parse(map['createdAt']),
      name: map['name'],
      description: map['description'],
    );
  }
}