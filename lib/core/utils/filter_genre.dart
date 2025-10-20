import 'package:noveles/features/data/local/models/model.dart';

//  Método para filtrar las Novelas por Genero
List<BookLocalModel> filterBooksByGenre(
    {required List<BookLocalModel> books, required String genre}) {
  return books.where((book) {
    return book.listGenre.any((g) => g.name == genre);
  }).toList();
}

//  Método para filtrar y mostrar los ultimo 5 Novelas por el "createdAt"
List<BookLocalModel> getLastFiveBooksByCreatedAt(
    {required List<BookLocalModel> books}) {
  // Ordenar los libros por fecha de creación en orden descendente
  books.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Tomar los primeros 5 libros de la lista ordenada
  return books.take(5).toList();
}

//  Método para filtrar y mostrar los ultimo 5 Novelas por el "id"
List<BookLocalModel> getLastFiveBooksById(
    {required List<BookLocalModel> books}) {
  // Ordenar los libros por id en orden descendente
  books.sort((a, b) => b.id.compareTo(a.id));

  // Tomar los primeros 5 libros de la lista ordenada
  return books.take(5).toList();
}
