/// Backend-neutral identity of the actor performing a request.
///
/// Deliberately free of any vendor type: adapters map their own session
/// representation onto this. The data layer only ever needs an id (and
/// optionally an email) to satisfy ownership columns such as `created_by`.
class AuthIdentity {
  final String id;
  final String? email;

  const AuthIdentity({required this.id, this.email});

  @override
  bool operator ==(Object other) =>
      other is AuthIdentity && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);

  @override
  String toString() => 'AuthIdentity($id)';
}
