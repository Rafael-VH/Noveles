import 'package:noveles/features/books/domain/book_with_relations.dart';

class GetBooksByGenre {
  List<BookWithRelations> call(List<BookWithRelations> books, String genre) {
    return books
        .where((book) => book.listGenre.any((g) => g.name == genre))
        .toList();
  }
}
