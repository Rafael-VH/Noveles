class AuthorEntity {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;

  AuthorEntity({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  AuthorEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
  }) {
    return AuthorEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'description': description,
    };
  }

  factory AuthorEntity.fromMap(Map<String, dynamic> map) {
    return AuthorEntity(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
