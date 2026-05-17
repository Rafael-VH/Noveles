import 'package:noveles/features/domain/entities/entities.dart';

class GetBooksByGenre {
  List<BookEntity> call(List<BookEntity> books, String genre) {
    return books
        .where((book) => book.listGenre.any((g) => g.name == genre))
        .toList();
  }
}
