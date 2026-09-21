import 'package:noveles/core/backend/auth_identity.dart';
import 'package:noveles/core/backend/data_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [DataGateway] backed by Supabase (PostgREST over Postgres).
///
/// This file — plus its siblings in this directory — is the only place in
/// `lib/` allowed to know PostgREST exists. In particular the embedded-resource
/// syntax used by the aggregate reads lives here and nowhere else, so replacing
/// the backend means writing a second adapter instead of hunting down join
/// strings across the feature repositories.
class SupabaseDataGateway implements DataGateway {
  final SupabaseClient _client;
  final AuthIdentity? _explicitIdentity;

  SupabaseDataGateway(this._client, [this._explicitIdentity]);

  @override
  DataGateway as(AuthIdentity? identity) =>
      SupabaseDataGateway(_client, identity);

  @override
  AuthIdentity? get identity {
    // Supabase attaches the session credential to the client itself, so the
    // effective identity is the session user unless one was set explicitly.
    // An adapter that manages its own connections must apply the explicit
    // identity for real, or the backend would evaluate authorization as the
    // wrong role.
    final explicit = _explicitIdentity;
    if (explicit != null) return explicit;
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthIdentity(id: user.id, email: user.email);
  }

  @override
  DbQuery from(String table) => _SupabaseDbQuery(_client, table);

  @override
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> values, {
    String? returning,
  }) async {
    if (returning == null) {
      await _client.from(table).insert(values);
      return null;
    }
    return await _client.from(table).insert(values).select(returning).single();
  }

  @override
  Future<dynamic> rpc(String function, {Map<String, dynamic>? params}) async {
    return await _client.rpc(function, params: params);
  }

  // ── Aggregate reads ────────────────────────────────────────────────────
  // PostgREST embed strings are confined to these constants.

  static const String _bookProjection =
      '*, authors(*), books_genres(genre_id, genres(*)), books_labels(*, labels(*)), tooks(*, chapters(*))';
  static const String _bookContentTreeProjection =
      'cover, tooks(chapters(content), cover)';
  static const String _tookProjection = '*, chapters(*)';

  @override
  Future<List<Map<String, dynamic>>> booksWithRelations({
    bool onlyVisible = false,
    required int limit,
    required int offset,
  }) async {
    var query = _client.from('books').select(_bookProjection);
    if (onlyVisible) {
      query = query.eq('is_visible', true);
    }
    return await query
        .order('id')
        .limit(limit)
        .range(offset, offset + limit - 1);
  }

  @override
  Future<Map<String, dynamic>?> bookWithRelationsById(int id) =>
      _client.from('books').select(_bookProjection).eq('id', id).maybeSingle();

  @override
  Future<List<Map<String, dynamic>>> booksWithRelationsByIds(
    List<int> ids,
  ) =>
      _client.from('books').select(_bookProjection).inFilter('id', ids);

  @override
  Future<Map<String, dynamic>?> bookContentTree(int id) => _client
      .from('books')
      .select(_bookContentTreeProjection)
      .eq('id', id)
      .maybeSingle();

  @override
  Future<List<Map<String, dynamic>>> tooksWithChapters({
    int? bookId,
    required int limit,
  }) async {
    var query = _client.from('tooks').select(_tookProjection);
    final id = bookId;
    if (id != null) {
      query = query.eq('book_id', id);
    }
    return await query.order('id').limit(limit);
  }

  @override
  Future<Map<String, dynamic>?> tookWithChaptersById(int id) =>
      _client.from('tooks').select(_tookProjection).eq('id', id).maybeSingle();
}

/// [DbQuery] that accumulates filters and renders them to PostgREST.
class _SupabaseDbQuery implements DbQuery {
  final SupabaseClient _client;
  final String _table;

  String _projection = '*';
  final List<(String, Object)> _equals = [];
  final List<(String, List<Object>)> _inLists = [];
  final List<(String, bool)> _orders = [];
  int? _limit;
  (int, int)? _range;

  _SupabaseDbQuery(this._client, this._table);

  @override
  DbQuery select([String projection = '*']) {
    _projection = projection;
    return this;
  }

  @override
  DbQuery eq(String column, Object value) {
    _equals.add((column, value));
    return this;
  }

  @override
  DbQuery inList(String column, List<Object> values) {
    _inLists.add((column, values));
    return this;
  }

  @override
  DbQuery order(String column, {bool ascending = true}) {
    _orders.add((column, ascending));
    return this;
  }

  @override
  DbQuery limit(int count) {
    _limit = count;
    return this;
  }

  @override
  DbQuery range(int from, int to) {
    _range = (from, to);
    return this;
  }

  /// Reads apply filters, then ordering and pagination.
  ///
  /// The two phases are separate because PostgREST's filter builder and its
  /// transform builder are different types.
  PostgrestTransformBuilder<PostgrestList> _read() {
    var filtered = _client.from(_table).select(_projection);
    for (final (column, value) in _equals) {
      filtered = filtered.eq(column, value);
    }
    for (final (column, values) in _inLists) {
      filtered = filtered.inFilter(column, values);
    }

    PostgrestTransformBuilder<PostgrestList> query = filtered;
    for (final (column, ascending) in _orders) {
      query = query.order(column, ascending: ascending);
    }
    final limit = _limit;
    if (limit != null) {
      query = query.limit(limit);
    }
    final range = _range;
    if (range != null) {
      query = query.range(range.$1, range.$2);
    }
    return query;
  }

  /// Writes only need the filters.
  dynamic _write(dynamic builder) {
    for (final (column, value) in _equals) {
      builder = builder.eq(column, value);
    }
    for (final (column, values) in _inLists) {
      builder = builder.inFilter(column, values);
    }
    return builder;
  }

  @override
  Future<List<Map<String, dynamic>>> rows() => _read();

  @override
  Future<Map<String, dynamic>?> maybeRow() => _read().maybeSingle();

  @override
  Future<Map<String, dynamic>> oneRow() => _read().single();

  @override
  Future<void> update(Map<String, dynamic> values) async {
    await _write(_client.from(_table).update(values));
  }

  @override
  Future<Map<String, dynamic>?> updateReturning(
    Map<String, dynamic> values,
  ) async {
    final result = await _write(_client.from(_table).update(values).select());
    return (result as List?)?.firstOrNull as Map<String, dynamic>?;
  }

  @override
  Future<void> delete() async {
    await _write(_client.from(_table).delete());
  }
}
