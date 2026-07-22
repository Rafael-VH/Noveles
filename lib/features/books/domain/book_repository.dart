import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

abstract class BookRepository {
  Future<Result<List<BookWithRelations>>> getBooks({
    bool onlyVisible = false,
    int page = 1,
    int pageSize = 50,
  });
  Future<Result<BookWithRelations?>> getBookById(int id);
  Future<Result<void>> toggleBookVisibility(int bookId, bool isVisible);
  Future<Result<int>> createBook(BookEntity book);
  Future<Result<void>> updateBook(BookEntity book);
  Future<Result<void>> deleteBook(int id);
  Future<Result<String>> uploadImage(String filePath);
  Future<Result<Map<int, Set<int>>>> getBookLabels(List<BookEntity> books);
  Future<Result<void>> trackBookView(int bookId);
  Future<Result<List<BookWithRelations>>> getRecentViews(String userId);
  Future<Result<List<BookWithRelations>>> getMostViewedBooks();
}
