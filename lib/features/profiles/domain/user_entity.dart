import 'package:equatable/equatable.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final UserRole role;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.displayName,
    this.bio,
    this.avatarUrl,
  });

  bool get isScan => role == UserRole.scan;
  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;
  bool get isSuspended => role == UserRole.suspended;

  @override
  List<Object> get props => [
        id,
        email,
        role,
        displayName ?? '',
        bio ?? '',
        avatarUrl ?? '',
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
