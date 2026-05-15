class UserEntity {
  final String id;
  final String email;
  final String role;

  UserEntity({
    required this.id,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}
