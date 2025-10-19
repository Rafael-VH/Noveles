import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class UpdateGenre {
  final GenreRepository repository;

  UpdateGenre(this.repository);

  Future<void> call(GenreEntity genre) async {
    return await repository.updateGenre(genre);
  }
}
