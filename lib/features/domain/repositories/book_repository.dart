import 'package:noveles/features/domain/entities/entities.dart';

abstract class BookRepository {
  Future<List<BookEntity>> getBooks({bool onlyVisible = false});
  Future<BookEntity?> getBookById(int id);
  Future<void> toggleBookVisibility(int bookId, bool isVisible);
  Future<void> createBook(BookEntity book);
  Future<void> updateBook(BookEntity book);
  Future<void> deleteBook(int id);
  Future<String> uploadCover(String filePath);
}
