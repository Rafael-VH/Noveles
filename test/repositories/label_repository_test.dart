import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/labels/data/label_repository_impl.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClientProvider extends Mock implements SupabaseClientProvider {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// ignore: must_be_immutable
class MockFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {
  PostgrestList? _data;

  void thenReturns(PostgrestList data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(PostgrestList value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data!);
    if (result is Future<U>) return result;
    return result;
  }
}

void main() {
  late MockSupabaseClientProvider mockProvider;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
  late LabelRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(LabelEntity(
      id: 0,
      createdAt: DateTime(2024),
      name: '',
      color: '',
    ));
  });

  setUp(() {
    mockProvider = MockSupabaseClientProvider();
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();

    when(() => mockProvider.client).thenReturn(mockClient);

    repository = LabelRepositoryImpl(mockProvider);

    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.insert(
          any(),
          defaultToNull: any(named: 'defaultToNull'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.update(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.delete()).thenAnswer((_) => mockFilter);
    when(() => mockFilter.eq(any(), any())).thenAnswer((_) => mockFilter);
    when(() => mockFilter.order(
          any(),
          ascending: any(named: 'ascending'),
          nullsFirst: any(named: 'nullsFirst'),
          referencedTable: any(named: 'referencedTable'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockFilter.limit(
          any(),
          referencedTable: any(named: 'referencedTable'),
        )).thenAnswer((_) => mockFilter);
  });

  tearDown(() {
    // No cleanup needed - setUp reinitializes all mocks
  });

  group('LabelRepositoryImpl', () {
    group('getLabels', () {
      test('returns list of LabelEntity on success', () async {
        mockFilter.thenReturns([
          {
            'id': 1,
            'created_at': '2024-01-01T00:00:00.000',
            'name': 'Label 1',
            'color': '#FF0000',
          },
          {
            'id': 2,
            'created_at': '2024-01-02T00:00:00.000',
            'name': 'Label 2',
            'color': '#00FF00',
          },
        ]);

        final result = await repository.getLabels();

        expect(result, isA<Ok<List<LabelEntity>>>());
        final value = (result as Ok<List<LabelEntity>>).value;
        expect(value.length, 2);
        expect(value.first.name, 'Label 1');
        expect(value.first.color, '#FF0000');
        verify(() => mockClient.from('labels')).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.order(
              any(),
              ascending: any(named: 'ascending'),
              nullsFirst: any(named: 'nullsFirst'),
              referencedTable: any(named: 'referencedTable'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getLabels();
        expect(result, isA<Err<List<LabelEntity>>>());
        final error = (result as Err<List<LabelEntity>>).error;
        expect(error.message, contains('Error al obtener etiquetas'));
      });
    });

    group('createLabel', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.createLabel(LabelEntity(
          id: 0,
          createdAt: DateTime(2024),
          name: 'New Label',
          color: '#FF0000',
        ));

        expect(result, isA<Ok<void>>());
        verify(() => mockQueryBuilder.insert(
              any(),
              defaultToNull: any(named: 'defaultToNull'),
            )).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockQueryBuilder.insert(
              any(),
              defaultToNull: any(named: 'defaultToNull'),
            )).thenThrow(Exception('Insert failed'));

        final result = await repository.createLabel(LabelEntity(
          id: 0,
          createdAt: DateTime(2024),
          name: 'New Label',
          color: '#FF0000',
        ));
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al crear etiqueta'));
      });
    });

    group('updateLabel', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.updateLabel(1, 'Updated', '#0000FF');

        expect(result, isA<Ok<void>>());
        verify(() => mockFilter.eq('id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateLabel(1, 'Updated', '#0000FF');
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar etiqueta'));
      });
    });

    group('deleteLabel', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.deleteLabel(1);

        expect(result, isA<Ok<void>>());
        verify(() => mockFilter.eq('id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteLabel(1);
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar etiqueta'));
      });
    });

    group('assignLabel', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.assignLabel(1, 2);

        expect(result, isA<Ok<void>>());
        verify(() => mockClient.from('books_labels')).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockQueryBuilder.insert(
              any(),
              defaultToNull: any(named: 'defaultToNull'),
            )).thenThrow(Exception('Assign failed'));

        final result = await repository.assignLabel(1, 2);
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al asignar etiqueta'));
      });
    });

    group('removeLabel', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.removeLabel(1, 2);

        expect(result, isA<Ok<void>>());
        verify(() => mockFilter.eq('book_id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Remove failed'));

        final result = await repository.removeLabel(1, 2);
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al quitar etiqueta'));
      });
    });
  });
}
