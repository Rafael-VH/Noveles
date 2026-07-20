import 'package:noveles/features/profiles/domain/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    super.displayName,
    super.bio,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: (json['email'] as String?) ?? '',
        role: _validateRole(json['role'] as String?),
        displayName: json['display_name'] as String?,
        bio: json['bio'] as String?,
        avatarUrl: json['avatar_url'] as String?,
      );

  static String _validateRole(String? role) {
    const validRoles = {'user', 'admin', 'scan'};
    final r = role ?? 'user';
    if (!validRoles.contains(r)) return 'user';
    return r;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'display_name': displayName,
        'bio': bio,
        'avatar_url': avatarUrl,
      };

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        role: entity.role,
        displayName: entity.displayName,
        bio: entity.bio,
        avatarUrl: entity.avatarUrl,
      );
}
