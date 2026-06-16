import 'package:noveles/features/books/domain/book_entity.dart';

abstract class BookRepository {
  Future<List<BookEntity>> getBooks({bool onlyVisible = false});
  Future<BookEntity?> getBookById(int id);
  Future<void> toggleBookVisibility(int bookId, bool isVisible);
  Future<void> createBook(BookEntity book);
  Future<void> updateBook(BookEntity book);
  Future<void> deleteBook(int id);
  Future<String> uploadCover(String filePath);
  Future<Map<int, Set<int>>> getBookLabels();
}
