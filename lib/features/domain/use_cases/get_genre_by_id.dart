import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetGenreById {
  final GenreRepository repository;

  GetGenreById(this.repository);

  Future<GenreEntity?> call(int id) async {
    return await repository.getGenreById(id);
  }
}
