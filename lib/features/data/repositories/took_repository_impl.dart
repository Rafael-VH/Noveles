import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class TookRepositoryImpl implements TookRepository {
  @override
  Future<List<TookEntity>> getTooks() async {
    final response = await supabase
        .from('tooks')
        .select('*, chapters(*)')
        .order('id');

    return response.map((json) => _mapToTookEntity(Map<String, dynamic>.from(json))).toList();
  }

  @override
  Future<TookEntity?> getTookById(int id) async {
    final response = await supabase
        .from('tooks')
        .select('*, chapters(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapToTookEntity(Map<String, dynamic>.from(response));
  }

  TookEntity _mapToTookEntity(Map<String, dynamic> json) {
    final chapters = (json['chapters'] as List<dynamic>)
        .map((ch) => ChapterEntity.fromMap(Map<String, dynamic>.from(ch)))
        .toList();
    json['listChapter'] = chapters;
    return TookEntity.fromMap(json);
  }

  @override
  Future<void> createTook(TookEntity took) async {
    await supabase.from('tooks').insert(took.toMap());
  }

  @override
  Future<void> updateTook(TookEntity took) async {
    await supabase.from('tooks').update(took.toMap()).eq('id', took.id);
  }

  @override
  Future<void> deleteTook(int id) async {
    await supabase.from('tooks').delete().eq('id', id);
  }
}
