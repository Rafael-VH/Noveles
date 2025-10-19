import 'package:noveles/features/main/domain/entities/entities.dart';

abstract class BookRepository {
  Future<List<BookEntity>> getBooks();
  Future<BookEntity?> getBookById(int id);
  Future<void> createBook(BookEntity book);
  Future<void> updateBook(BookEntity book);
  Future<void> deleteBook(int id);
}