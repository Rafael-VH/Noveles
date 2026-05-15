import 'package:flutter/material.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/pages/pages.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({
    super.key,
    required this.genre,
    required this.books,
  });

  final String genre;
  final List<BookEntity> books;

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  late final List<BookEntity> filteredBooks;

  @override
  void initState() {
    super.initState();
    filteredBooks = widget.books
        .where((book) => book.listGenre.any((g) => g.name == widget.genre))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return GenrePage(
      books: filteredBooks,
      genre: widget.genre,
    );
  }
}
