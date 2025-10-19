import 'package:flutter/material.dart';
import 'package:noveles/core/utils/filter_genre.dart';
import 'package:noveles/features/main/data/local/models/model.dart';
import 'package:noveles/features/main/presentation/pages/pages.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({
    super.key,
    required this.genre,
    required this.books,
  });

  final String genre;
  final List<BookLocalModel> books;

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  // Utiliza la función de filtrado
  late final List<BookLocalModel> filteredBooks;

  @override
  void initState() {
    super.initState();
    // Filtrar los libros en initState
    filteredBooks = filterBooksByGenre(books: widget.books, genre: widget.genre);
  }

  @override
  Widget build(BuildContext context) {
    return GenrePage(
      books: filteredBooks,
      genre: widget.genre,
    );
  }
}
