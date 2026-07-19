import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({
    super.key,
    required this.genre,
    required this.books,
    required this.coverUrlService,
  });

  final String genre;
  final List<BookWithRelations> books;
  final CoverUrlService coverUrlService;

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  late final List<BookWithRelations> filteredBooks;

  @override
  void initState() {
    super.initState();
    filteredBooks = widget.books
        .where((b) => b.listGenre.any((g) => g.name == widget.genre))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Género: ${widget.genre}'),
      ),
      body: filteredBooks.isEmpty
          ? const Center(
              child: Text('No hay libros disponibles para este género'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.65,
              ),
              itemCount: filteredBooks.length,
              itemBuilder: (BuildContext context, int index) {
                final book = filteredBooks[index];

                return Card(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.coverUrlService(book.cover),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.book, size: 48),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withValues(alpha: 0.5),
                                Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withValues(alpha: 0.7),
                                Theme.of(context).colorScheme.surface,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4.0,
                        right: 4.0,
                        bottom: 8.0,
                        child: Text(
                          book.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
