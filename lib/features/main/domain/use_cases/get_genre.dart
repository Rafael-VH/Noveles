import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class GetGenre {
  final GenreRepository repository;

  GetGenre(this.repository);

  Future<List<GenreEntity>> call() async {
    return await repository.getGenres();
  }
}
