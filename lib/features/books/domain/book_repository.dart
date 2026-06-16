import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_entity.dart';

abstract class BookRepository {
  Future<Result<List<BookEntity>>> getBooks({bool onlyVisible = false});
  Future<Result<BookEntity?>> getBookById(int id);
  Future<Result<void>> toggleBookVisibility(int bookId, bool isVisible);
  Future<Result<void>> createBook(BookEntity book);
  Future<Result<void>> updateBook(BookEntity book);
  Future<Result<void>> deleteBook(int id);
  Future<Result<String>> uploadCover(String filePath);
  Future<Result<Map<int, Set<int>>>> getBookLabels();
}
