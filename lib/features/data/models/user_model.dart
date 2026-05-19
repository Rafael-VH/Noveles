import 'package:noveles/features/domain/entities/entities.dart';

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
    role: (json['role'] as String?) ?? 'user',
    displayName: json['display_name'] as String?,
    bio: json['bio'] as String?,
    avatarUrl: json['avatar_url'] as String?,
  );

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
