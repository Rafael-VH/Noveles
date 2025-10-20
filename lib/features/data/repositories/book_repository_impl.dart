import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl(Object object);

  // Aquí iría tu fuente de datos, por ejemplo, una base de datos local o una API

  @override
  Future<BookEntity?> getBookById(int id) async {
    // Implementación para obtener un libro por ID
  }

  @override
  Future<void> createBook(BookEntity book) async {
    // Implementación para crear un libro
  }

  @override
  Future<void> updateBook(BookEntity book) async {
    // Implementación para actualizar un libro
  }

  @override
  Future<void> deleteBook(int id) async {
    // Implementación para eliminar un libro
  }

  @override
  Future<List<BookEntity>> getBooks() {
    // TODO: implement getBooks
    throw UnimplementedError();
  }
}
