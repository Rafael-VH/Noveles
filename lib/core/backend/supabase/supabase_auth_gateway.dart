import 'package:noveles/core/backend/auth_gateway.dart';
import 'package:noveles/core/backend/auth_identity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [AuthGateway] backed by Supabase Auth (GoTrue).
class SupabaseAuthGateway implements AuthGateway {
  final SupabaseClient _client;

  SupabaseAuthGateway(this._client);

  GoTrueClient get _auth => _client.auth;

  @override
  Future<AuthIdentity?> signIn(String email, String password) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _toIdentity(response.user);
  }

  @override
  Future<AuthIdentity?> signUp(String email, String password) async {
    final response = await _auth.signUp(email: email, password: password);
    return _toIdentity(response.user);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  AuthIdentity? get currentIdentity => _toIdentity(_auth.currentUser);

  @override
  bool get hasSession => _auth.currentSession != null;

  @override
  Stream<AuthIdentityEvent> stateChanges() => _auth.onAuthStateChange.map(
        (data) => switch (data.event) {
          AuthChangeEvent.signedIn => AuthIdentityEvent.signedIn,
          AuthChangeEvent.signedOut => AuthIdentityEvent.signedOut,
          AuthChangeEvent.tokenRefreshed => AuthIdentityEvent.tokenRefreshed,
          AuthChangeEvent.userUpdated => AuthIdentityEvent.userUpdated,
          _ => AuthIdentityEvent.unknown,
        },
      );

  @override
  Future<void> updatePassword(String newPassword) =>
      _auth.updateUser(UserAttributes(password: newPassword));

  AuthIdentity? _toIdentity(User? user) => user == null
      ? null
      : AuthIdentity(id: user.id, email: user.email);
}
