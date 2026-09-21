import 'package:noveles/core/backend/auth_identity.dart';

/// Session lifecycle events, expressed without vendor types.
///
/// Feature code maps these onto its own domain vocabulary (see
/// `AuthRepositoryImpl`), which keeps the vendor enum out of `domain/`.
enum AuthIdentityEvent {
  signedIn,
  signedOut,
  tokenRefreshed,
  userUpdated,
  unknown,
}

/// Port for authentication.
abstract class AuthGateway {
  /// Sign in and return the resulting identity, or `null` when the backend
  /// reports no user (some backends require confirmation first).
  Future<AuthIdentity?> signIn(String email, String password);

  /// Register and return the resulting identity, or `null` when the backend
  /// reports no user.
  Future<AuthIdentity?> signUp(String email, String password);

  Future<void> signOut();

  /// The signed-in identity, or `null`.
  AuthIdentity? get currentIdentity;

  /// Whether a session is currently held.
  bool get hasSession;

  /// Emits on session changes. Errors surface through the stream's error
  /// channel.
  Stream<AuthIdentityEvent> stateChanges();

  /// Change the current user's password.
  Future<void> updatePassword(String newPassword);
}
