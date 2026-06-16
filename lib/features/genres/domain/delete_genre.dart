import 'package:noveles/features/genres/domain/genre_repository.dart';

class DeleteGenre {
  final GenreRepository repository;

  DeleteGenre(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteGenre(id);
  }
}
