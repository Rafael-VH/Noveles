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
}
