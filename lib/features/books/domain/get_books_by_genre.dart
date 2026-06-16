import 'package:noveles/features/books/domain/book_entity.dart';

class GetBooksByGenre {
  List<BookEntity> call(List<BookEntity> books, String genre) {
    return books
        .where((book) => book.listGenre.any((g) => g.name == genre))
        .toList();
  }
}
