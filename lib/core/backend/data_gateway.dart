import 'package:noveles/core/backend/auth_identity.dart';

/// Port for relational data access.
///
/// The point of this abstraction is that feature repositories depend on it
/// instead of a concrete client, so the backend underneath can be replaced
/// without touching `domain/` or `presentation/`.
///
/// Two rules keep it honest:
///
/// 1. **It is not a vendor client.** Nothing here exposes query strings,
///    embedded-resource syntax or HTTP details.
/// 2. **It is identity-aware.** Authorization may live in the database
///    (row level security). An adapter that opened a single elevated
///    connection would silently bypass all of it, so the contract forces the
///    adapter to propagate the acting identity.
abstract class DataGateway {
  /// Returns a gateway that runs as [identity].
  ///
  /// Adapters backed by a session-carrying client (where the credential is
  /// already attached to the connection) may treat this as a hint and rely on
  /// their own session; adapters that open connections themselves must apply
  /// it for real, or authorization is lost.
  DataGateway as(AuthIdentity? identity);

  /// The identity queries currently run as, if any.
  AuthIdentity? get identity;

  /// Start a query against [table].
  DbQuery from(String table);

  /// Insert a single row.
  ///
  /// When [returning] is provided the created row (projected to those columns)
  /// is returned; otherwise the method returns `null` and the database default
  /// is relied upon.
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> values, {
    String? returning,
  });

  /// Invoke a server-side function by name.
  Future<dynamic> rpc(String function, {Map<String, dynamic>? params});

  // ─── Named aggregate reads ──────────────────────────────────────────────
  // Relationships (a book with its authors, genres, labels, tooks and
  // chapters) cannot be expressed portably: every backend spells joins
  // differently. Rather than leak one backend's syntax across the feature
  // repositories, the aggregates are named here and their implementation
  // stays inside the adapter.

  /// Books with their full relation tree, ordered by id.
  Future<List<Map<String, dynamic>>> booksWithRelations({
    bool onlyVisible = false,
    required int limit,
    required int offset,
  });

  /// A single book with its full relation tree.
  Future<Map<String, dynamic>?> bookWithRelationsById(int id);

  /// Books with their full relation tree, restricted to [ids].
  Future<List<Map<String, dynamic>>> booksWithRelationsByIds(List<int> ids);

  /// The cover and chapter-content tree of a book, used before deleting it so
  /// orphaned storage objects can be cleaned up.
  Future<Map<String, dynamic>?> bookContentTree(int id);

  /// Tooks with their chapters, ordered by id.
  Future<List<Map<String, dynamic>>> tooksWithChapters({
    int? bookId,
    required int limit,
  });

  /// A single took with its chapters.
  Future<Map<String, dynamic>?> tookWithChaptersById(int id);
}

/// A filtered, ordered, paginated query against one table.
///
/// Filters accumulate until a terminal method runs. Terminal methods are
/// explicit (`rows`, `maybeRow`, `oneRow`, `update`, `delete`) so nothing
/// depends on implicit awaiting.
abstract class DbQuery {
  /// Columns (or relations) to return. Defaults to every column.
  DbQuery select([String projection = '*']);

  DbQuery eq(String column, Object value);

  DbQuery inList(String column, List<Object> values);

  DbQuery order(String column, {bool ascending = true});

  DbQuery limit(int count);

  DbQuery range(int from, int to);

  /// Every matching row.
  Future<List<Map<String, dynamic>>> rows();

  /// The matching row, or `null` when there is none.
  Future<Map<String, dynamic>?> maybeRow();

  /// The matching row; fails when there is none or more than one.
  Future<Map<String, dynamic>> oneRow();

  /// Update every matching row.
  Future<void> update(Map<String, dynamic> values);

  /// Update every matching row and return the resulting row (SQL
  /// `UPDATE ... RETURNING`).
  Future<Map<String, dynamic>?> updateReturning(Map<String, dynamic> values);

  /// Delete every matching row.
  Future<void> delete();
}
