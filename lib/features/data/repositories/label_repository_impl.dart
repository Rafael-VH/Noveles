import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/data/models/models.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class LabelRepositoryImpl implements LabelRepository {
  @override
  Future<List<LabelEntity>> getLabels() async {
    try {
      final response = await supabase
          .from('labels')
          .select()
          .order('id');
      return response.map((json) => LabelModel.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener etiquetas',
        originalException: e,
        repositoryName: 'LabelRepository',
      );
    }
  }

  @override
  Future<void> createLabel(String name, String color) async {
    try {
      await supabase.from('labels').insert({'name': name, 'color': color});
    } catch (e) {
      throw RepositoryException(
        message: 'Error al crear etiqueta',
        originalException: e,
        repositoryName: 'LabelRepository',
      );
    }
  }

  @override
  Future<void> deleteLabel(int id) async {
    try {
      await supabase.from('labels').delete().eq('id', id);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al eliminar etiqueta',
        originalException: e,
        repositoryName: 'LabelRepository',
      );
    }
  }

  @override
  Future<void> assignLabel(int bookId, int labelId) async {
    try {
      await supabase.from('books_labels').insert({
        'book_id': bookId,
        'label_id': labelId,
      });
    } catch (e) {
      throw RepositoryException(
        message: 'Error al asignar etiqueta',
        originalException: e,
        repositoryName: 'LabelRepository',
      );
    }
  }

  @override
  Future<void> removeLabel(int bookId, int labelId) async {
    try {
      await supabase
          .from('books_labels')
          .delete()
          .eq('book_id', bookId)
          .eq('label_id', labelId);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al quitar etiqueta',
        originalException: e,
        repositoryName: 'LabelRepository',
      );
    }
  }
}
