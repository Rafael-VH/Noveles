import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/backend/auth_gateway.dart';
import 'package:noveles/core/backend/auth_identity.dart';
import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/backend/storage_gateway.dart';

/// Test doubles for the backend ports in `lib/core/backend`.
///
/// Repositories depend on the ports instead of the vendor SDK, so the tests no
/// longer need PostgREST builders — nor the `then()` override those required.
/// The ports expose explicit terminals (`rows`, `maybeRow`, `oneRow`, `update`,
/// `delete`), so ordinary `when(...).thenAnswer(...)` stubbing works.
class MockDataGateway extends Mock implements DataGateway {}

class MockDbQuery extends Mock implements DbQuery {}

class MockAuthGateway extends Mock implements AuthGateway {}

class MockStorageGateway extends Mock implements StorageGateway {}

/// A wired backend: one query builder per table, plus auth and storage doubles.
///
/// Queries are scoped per table on purpose. A repository that reads two tables
/// (`chapters`, then `chapter_reads`) gets a distinct builder for each, so a
/// stub registered for one can never silently answer for the other.
///
/// Every builder is created in the constructor. Registering them lazily would
/// mean calling `when` from inside another `when` the first time a test stubbed
/// a terminal, which corrupts mocktail's matcher state.
class FakeBackend {
  FakeBackend() {
    registerFallbackValue(File(''));
    // Sensible default: nobody is signed in. Tests opt in with [signedInAs].
    when(() => auth.hasSession).thenReturn(false);
    // `insert` returns the created row only when the caller asks for it, so the
    // un-returning call sites resolve to null. Mocktail matches named-argument
    // key sets exactly, so both shapes need their own stub.
    when(() => data.insert(any(), any())).thenAnswer((_) async => null);
    when(() => data.insert(any(), any(), returning: any(named: 'returning')))
        .thenAnswer((_) async => null);

    for (final table in _tables) {
      _queries[table] = _buildQuery(table);
    }
  }

  /// Every table the repositories touch. Kept explicit so a typo in a test
  /// fails loudly instead of quietly returning nothing.
  static const Set<String> _tables = {
    'genres',
    'labels',
    'label_rules',
    'books',
    'books_labels',
    'book_views',
    'tooks',
    'chapters',
    'chapter_reads',
    'profiles',
    'user_favorites',
  };

  final MockDataGateway data = MockDataGateway();
  final MockAuthGateway auth = MockAuthGateway();
  final MockStorageGateway storage = MockStorageGateway();

  final Map<String, MockDbQuery> _queries = {};

  /// The builder `from(table)` hands out, with the fluent chain wired so
  /// filters, ordering and pagination accumulate onto the same instance.
  MockDbQuery query(String table) =>
      _queries[table] ??
      (throw ArgumentError.value(table, 'table', 'Unknown table'));

  MockDbQuery _buildQuery(String table) {
    final builder = MockDbQuery();
    when(() => builder.select(any())).thenReturn(builder);
    when(() => builder.eq(any(), any())).thenReturn(builder);
    when(() => builder.inList(any(), any())).thenReturn(builder);
    when(() => builder.order(any(), ascending: any(named: 'ascending')))
        .thenReturn(builder);
    when(() => builder.limit(any())).thenReturn(builder);
    when(() => builder.range(any(), any())).thenReturn(builder);
    when(() => data.from(table)).thenReturn(builder);
    return builder;
  }

  // ─── Terminals ──────────────────────────────────────────────────────────

  /// Stubs `rows()` for [table].
  void rows(String table, List<Map<String, dynamic>> value) =>
      when(() => query(table).rows()).thenAnswer((_) async => value);

  /// Stubs `maybeRow()` for [table].
  void maybeRow(String table, Map<String, dynamic>? value) =>
      when(() => query(table).maybeRow()).thenAnswer((_) async => value);

  /// Stubs `oneRow()` for [table].
  void oneRow(String table, Map<String, dynamic> value) =>
      when(() => query(table).oneRow()).thenAnswer((_) async => value);

  /// Stubs `update(...)` to succeed for [table]. Inspect the payload afterwards
  /// with [capturedUpdate].
  void updateOk(String table) =>
      when(() => query(table).update(any())).thenAnswer((_) async {});

  /// Stubs `delete()` to succeed for [table].
  void deleteOk(String table) =>
      when(() => query(table).delete()).thenAnswer((_) async {});

  /// Stubs `updateReturning(...)` for [table].
  void updateReturning(String table, Map<String, dynamic>? value) =>
      when(() => query(table).updateReturning(any()))
          .thenAnswer((_) async => value);

  /// Stubs an `insert` whose created row is requested back as `{'id': id}`.
  void insertReturnsId(String table, int id) => when(() => data.insert(
        table,
        any(),
        returning: any(named: 'returning'),
      )).thenAnswer((_) async => {'id': id});

  /// Stubs `insert` to succeed without returning a row, in both shapes.
  void insertOk(String table) {
    when(() => data.insert(table, any())).thenAnswer((_) async => null);
    when(() => data.insert(
          table,
          any(),
          returning: any(named: 'returning'),
        )).thenAnswer((_) async => null);
  }

  // ─── Captures ───────────────────────────────────────────────────────────

  /// The row map handed to a plain `insert(table, values)` call.
  Map<String, dynamic> capturedInsert(String table) {
    final captured = verify(() => data.insert(table, captureAny())).captured;
    return Map<String, dynamic>.from(captured.single as Map);
  }

  /// The row map handed to `insert(table, values, returning: ...)`.
  Map<String, dynamic> capturedInsertReturning(String table) {
    final captured = verify(() => data.insert(
          table,
          captureAny(),
          returning: any(named: 'returning'),
        )).captured;
    return Map<String, dynamic>.from(captured.single as Map);
  }

  /// The values map handed to `update(...)` on the last matching call.
  Map<String, dynamic> capturedUpdate(String table) {
    final captured = verify(() => query(table).update(captureAny())).captured;
    return Map<String, dynamic>.from(captured.single as Map);
  }

  /// The values map handed to `updateReturning(...)` on the last call.
  Map<String, dynamic> capturedUpdateReturning(String table) {
    final captured =
        verify(() => query(table).updateReturning(captureAny())).captured;
    return Map<String, dynamic>.from(captured.single as Map);
  }

  /// The params map handed to `rpc(function, ...)` on the last matching call.
  Map<String, dynamic> capturedRpcParams(String function) {
    final captured = verify(
      () => data.rpc(function, params: captureAny(named: 'params')),
    ).captured;
    return Map<String, dynamic>.from(captured.single as Map);
  }

  // ─── Identity ───────────────────────────────────────────────────────────

  /// Makes the data gateway act as [id] and gives auth a live session.
  AuthIdentity signedInAs(String id, {String? email}) {
    final identity = AuthIdentity(id: id, email: email);
    when(() => data.identity).thenReturn(identity);
    when(() => auth.currentIdentity).thenReturn(identity);
    when(() => auth.hasSession).thenReturn(true);
    return identity;
  }

  // ─── Storage ────────────────────────────────────────────────────────────

  /// Stubs a plain `upload(bucket, path, file)` to succeed.
  void uploadOk() =>
      when(() => storage.upload(any(), any(), any())).thenAnswer((_) async {});

  /// Stubs the overwrite path, `upload(..., upsert: true)`, to succeed.
  void uploadOkUpsert() => when(() => storage.upload(
        any(),
        any(),
        any(),
        upsert: any(named: 'upsert'),
      )).thenAnswer((_) async {});

  /// Stubs `remove` to succeed.
  void removeOk() =>
      when(() => storage.remove(any(), any())).thenAnswer((_) async {});
}
