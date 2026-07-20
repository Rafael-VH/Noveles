enum UserRole {
  user,
  scan,
  admin,
  suspended;

  /// Parse a role string into a [UserRole].
  /// Returns [UserRole.user] for unknown or null values.
  static UserRole fromString(String? role) {
    return switch (role) {
      'user' => UserRole.user,
      'scan' => UserRole.scan,
      'admin' => UserRole.admin,
      'suspended' => UserRole.suspended,
      _ => UserRole.user,
    };
  }
}
