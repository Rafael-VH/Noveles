enum UserRole {
  user,
  scan,
  admin,
  suspended,
  unknown;

  /// Parse a role string into a [UserRole].
  /// Returns [UserRole.unknown] for unrecognized or null values so the caller
  /// can decide how to handle an inconsistent profile instead of silently
  /// treating the user as a regular `user`.
  static UserRole fromString(String? role) {
    return switch (role) {
      'user' => UserRole.user,
      'scan' => UserRole.scan,
      'admin' => UserRole.admin,
      'suspended' => UserRole.suspended,
      _ => UserRole.unknown,
    };
  }
}
