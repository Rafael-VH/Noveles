import 'package:noveles/core/supabase/supabase_client.dart';
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
      return response.map((json) => LabelEntity(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        name: json['name'] ?? '',
        color: json['color'] ?? '#71A202',
      )).toList();
    } catch (e) {
      throw Exception('Error al obtener etiquetas: $e');
    }
  }

  @override
  Future<void> createLabel(String name, String color) async {
    try {
      await supabase.from('labels').insert({'name': name, 'color': color});
    } catch (e) {
      throw Exception('Error al crear etiqueta: $e');
    }
  }

  @override
  Future<void> deleteLabel(int id) async {
    try {
      await supabase.from('labels').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar etiqueta: $e');
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
      throw Exception('Error al asignar etiqueta: $e');
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
      throw Exception('Error al quitar etiqueta: $e');
    }
  }
}
