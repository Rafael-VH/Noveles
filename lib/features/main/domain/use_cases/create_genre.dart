import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class CreateGenre {
  final GenreRepository repository;

  CreateGenre(this.repository);

  Future<void> call(GenreEntity genre) async {
    return await repository.createGenre(genre);
  }
}
