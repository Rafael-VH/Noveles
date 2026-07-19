import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/labels/data/label_model.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';

class LabelRepositoryImpl implements LabelRepository {
  final SupabaseClientProvider _supabase;

  LabelRepositoryImpl(this._supabase);

  @override
  Future<Result<List<LabelEntity>>> getLabels() async {
    try {
      final response =
          await _supabase.client.from('labels').select().order('id').limit(100);
      final labels = response.map((json) => LabelModel.fromJson(json)).toList();
      return Ok(labels);
    } catch (e) {
      return Err(LabelFailure('Error al obtener etiquetas', cause: e));
    }
  }

  @override
  Future<Result<void>> createLabel(LabelEntity label) async {
    try {
      await _supabase.client
          .from('labels')
          .insert({'name': label.name, 'color': label.color});
      return const Ok(null);
    } catch (e) {
      return Err(LabelFailure('Error al crear etiqueta', cause: e));
    }
  }

  @override
  Future<Result<void>> updateLabel(int id, String name, String color) async {
    try {
      await _supabase.client
          .from('labels')
          .update({'name': name, 'color': color}).eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(LabelFailure('Error al actualizar etiqueta', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteLabel(int id) async {
    try {
      await _supabase.client.from('labels').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(LabelFailure('Error al eliminar etiqueta', cause: e));
    }
  }

  @override
  Future<Result<void>> assignLabel(int bookId, int labelId) async {
    try {
      await _supabase.client.from('books_labels').insert({
        'book_id': bookId,
        'label_id': labelId,
      });
      return const Ok(null);
    } catch (e) {
      return Err(LabelFailure('Error al asignar etiqueta', cause: e));
    }
  }

  @override
  Future<Result<void>> removeLabel(int bookId, int labelId) async {
    try {
      await _supabase.client
          .from('books_labels')
          .delete()
          .eq('book_id', bookId)
          .eq('label_id', labelId);
      return const Ok(null);
    } catch (e) {
      return Err(LabelFailure('Error al quitar etiqueta', cause: e));
    }
  }

  @override
  Future<Result<Map<int, Set<int>>>> getBookLabels(List<int> bookIds) async {
    try {
      if (bookIds.isEmpty) return const Ok({});
      final rows = await _supabase.client
          .from('books_labels')
          .select()
          .filter('book_id', 'in', bookIds);
      final map = <int, Set<int>>{};
      for (final row in rows) {
        map.putIfAbsent(row['book_id'], () => {}).add(row['label_id']);
      }
      return Ok(map);
    } catch (e) {
      return Err(LabelFailure('Error al obtener etiquetas de libros', cause: e));
    }
  }
}
