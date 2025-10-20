import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetGenre {
  final GenreRepository repository;

  GetGenre(this.repository);

  Future<List<GenreEntity>> call() async {
    return await repository.getGenres();
  }
}
