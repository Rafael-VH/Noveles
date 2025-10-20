import 'package:noveles/features/domain/repositories/repositories.dart';

class DeleteGenre {
  final GenreRepository repository;

  DeleteGenre(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteGenre(id);
  }
}
