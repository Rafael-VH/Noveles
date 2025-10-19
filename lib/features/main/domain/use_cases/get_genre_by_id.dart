import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class GetGenreById {
  final GenreRepository repository;

  GetGenreById(this.repository);

  Future<GenreEntity?> call(int id) async {
    return await repository.getGenreById(id);
  }
}
